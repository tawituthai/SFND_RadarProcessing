clear all
clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

speedOfLight = 3e8;     % Can't go any faster!
radarFreq = 77e9;            % Radar Operating Frequency
rangeMax = 200;         % Radar maximum range requirement
rangeRes = 1;           % Radar range resolution requirement
targetSpeed_max = 100;  % Maximum target speed

%% User Defined Range and Velocity of target
% *%TODO* :
% define the target's initial position and velocity. Note : Velocity
% remains contant
 
targetPos = 130;
targetSpeed = 60;

%% FMCW Waveform Generation

% *%TODO* :
%Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.

% --- Calculate Chirp Bandwidth (Bchirp)
Bchirp = speedOfLight / (2*rangeRes);

% --- Calculate Chirp Time (Tchirp)
TchirpFactor = 5.5;     % Should in range of 5 - 6
Tchirp = (2 * TchirpFactor * rangeMax) / speedOfLight;

% ---Calculate Chirp Slope (SChirp)
Schirp = Bchirp / Tchirp;

%Operating carrier frequency of Radar 
fc= 77e9;             %carrier freq

                                                          
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples


%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));


%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 

for i=1:length(t)         
    
    %For each time stamp update the Range of the Target for constant velocity. 
    r_t(i) = targetPos + (targetSpeed * t(i));
    
    %For each time sample we need update the transmitted and
    %received signal. 
    % Calculate Time-delay base on position of target
    td(i) = 2 * r_t(i) / speedOfLight;
    
    % Transmiting Signal
    Tx(i) = cos(2 * pi * ( (radarFreq * t(i)) + ((Schirp * t(i)^2)/2) ) );
    % Receiving Signal, basically a time-delayed version of the transmitted
    % signal
    Rx(i) = cos(2 * pi * ( (radarFreq * (t(i)-td(i))) + ((Schirp * (t(i)-td(i))^2)/2) ) );
    
    %Now by mixing the Transmit and Receive generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    % Beat Signal
    Mix(i) = Tx(i) .* Rx(i);
    
end

%% RANGE MEASUREMENT

%run the FFT on the beat signal along the range bins dimension (Nr) and
%normalize.
signal_fft = fft(Mix, Nr)./Nr;

% Take the absolute value of FFT output
signal_fft = abs(signal_fft);

% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.
signal_fft = signal_fft(1:(Nr/2));

%plotting the range
figure ('Name','Range from First FFT')

 % plot FFT output 
plot(signal_fft);
axis ([0 200 0 1]);
xlabel('range(m), target at 130 m.');

%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM


% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift (sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure,surf(doppler_axis,range_axis,RDM);

%% CFAR implementation

%Slide Window through the complete Range Doppler Map

%Select the number of Training Cells in both the dimensions.
Tr = 10;    % Training range
Td = 8;     % Training Doppler

%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation
Gr = 5;
Gd = 5;

% Calculate number if train cell
TrainCellsize = (2 * (Td+Gd+1) * 2 * (Tr+Gr+1)) - (Gr*Gd) - 1;

% offset the threshold by SNR value in dB
offset_snr = 1.4;

%design a loop such that it slides the CUT across range doppler map by
%giving margins at the edges for Training and Guard Cells.
%For every iteration sum the signal level within all the training
%cells. To sum convert the value from logarithmic to linear using db2pow
%function. Average the summed values for all of the training
%cells used. After averaging convert it back to logarithimic using pow2db.
%Further add the offset to it to determine the threshold. Next, compare the
%signal under CUT with this threshold. If the CUT level > threshold assign
%it a value of 1, else equate it to 0.


   % Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
   % CFAR
   RDM = RDM/max(max(RDM)); % Normalizing
   
% *%TODO* :
% The process above will generate a thresholded block, which is smaller 
%than the Range Doppler Map as the CUT cannot be located at the edges of
%matrix. Hence,few cells will not be thresholded. To keep the map size same
% set those values to 0. 

% Within whole 2D data
for i = (Tr+Gr+1):(Nr/2)-(Tr+Gr)
    for j = (Td+Gd+1):Nd-(Td+Gd)
        %Create a vector to store noise_level for each iteration on training cells
        noise_level = zeros(1,1);
        % Within Training Band
        for x = i-(Tr+Gr) : i+(Tr+Gr)
            for y = j-(Td+Gd) : j+(Td+Gd)
                %Skip cells within Guard band
                if (abs(i-x) > Gr || abs(j-y) > Gd)
                    %calculate noise level
                    noise_level = noise_level + db2pow(RDM(x,y));
                end
            end
        end
        % END -- within training band
        
        noiseNorm = noise_level/TrainCellsize;
        % Calculate threshold, convert back to db first
        threshold = pow2db(noiseNorm);
        % Add SNR offset
        threshold = threshold + offset_snr;
        
        % Check noise value at CUT cell
        CUT = RDM(i,j);
        % Check if CUT exceeding threshold value
        if (CUT < threshold)
            RDM(i,j) = 0;
        else
            RDM(i,j) = 1;
        end
        
    end
end

% Noise suppression, at 4 side of the map
RDM(RDM~=0 & RDM~=1) = 0;

% *%TODO* :
%display the CFAR output using the Surf function like we did for Range
%Doppler Response output.
figure,surf(doppler_axis,range_axis,RDM);
colorbar;


 

