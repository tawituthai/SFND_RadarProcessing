# Radar Target Generation and Detection
## FMCW Waveform Design
From giveb Radar system requirements, we can calculate `Chirp Bandwidth (Bchirp)`, `Chirp Time (Tchirp)`, and `Chirp Slope (Schirp)`.
| <img src="images/Radar_SystemRequirements.png" width="788" height="268" /> | 
|:--:| 
| *Given Radar System Requirements* |

### Chirp Bandwidth (Bchirp)
Chirp bandwidth can be calculate using the following equation

<a href="https://www.codecogs.com/eqnedit.php?latex=B_{chirp}&space;=&space;\frac{speedOfLight}{2*rangeRes}&space;=&space;\frac{3*10^8}{2*1}&space;=&space;1.5*10^8" target="_blank"><img src="https://latex.codecogs.com/png.latex?B_{chirp}&space;=&space;\frac{speedOfLight}{2*rangeRes}&space;=&space;\frac{3*10^8}{2*1}&space;=&space;1.5*10^8" title="B_{chirp} = \frac{speedOfLight}{2*rangeRes} = \frac{3*10^8}{2*1} = 1.5*10^8" /></a>

### Chirp Time (Tchirp)
Chirp Time can be calculate using formular as follow,

<a href="https://www.codecogs.com/eqnedit.php?latex=T_{chirp}&space;=&space;\frac{T_{factor}*2*Range_{max}}{speedOfLight}" target="_blank"><img src="https://latex.codecogs.com/png.latex?T_{chirp}&space;=&space;\frac{T_{factor}*2*Range_{max}}{speedOfLight}" title="T_{chirp} = \frac{T_{factor}*2*Range_{max}}{speedOfLight}" /></a>

where <a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;T_{factor}" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;T_{factor}" title="T_{factor}" /></a> is times of round trip time, and should be in range from 5 to 6. Using <a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;T_{factor}" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;T_{factor}" title="T_{factor}" /></a> of 5.5 we can calculate <a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;T_{chirp}" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;T_{chirp}" title="T_{chirp}" /></a> as,

<a href="https://www.codecogs.com/eqnedit.php?latex=T_{chirp}&space;=&space;\frac{5.5*2*200}{3*10^8}&space;=&space;7.334*10^{-6}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?T_{chirp}&space;=&space;\frac{5.5*2*200}{3*10^8}&space;=&space;7.334*10^{-6}" title="T_{chirp} = \frac{5.5*2*200}{3*10^8} = 7.334*10^{-6}" /></a>

### Chirp Slope (Schirp)
Chirp slope is basically a ratio between <a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;B_{chirp}" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;B_{chirp}" title="T_{chirp}" /></a> and <a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;T_{chirp}" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;T_{chirp}" title="T_{chirp}" /></a> using values calculated above we got

<a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;S_{chirp}&space;=&space;\frac{B_{chirp}}{T_{chirp}}&space;=&space;\frac{1.5*10^8}{7.334*10^{-6}}&space;=&space;2.045*10^{13}" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;S_{chirp}&space;=&space;\frac{B_{chirp}}{T_{chirp}}&space;=&space;\frac{1.5*10^8}{7.334*10^{-6}}&space;=&space;2.045*10^{13}" title="S_{chirp} = \frac{B_{chirp}}{T_{chirp}} = \frac{1.5*10^8}{7.334*10^{-6}} = 2.045*10^{13}" /></a>

## Simulation Loop
For this simulation, I choose target position to be at 130 m. away and moving at constant speed of 60 m/s. both within range of the Radar system requirements.

Position of the target overtime can simply calculate using linear motion equation.

<a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;target_{position}&space;=&space;target_{initPosition}&space;&plus;&space;(target_{velocity}*time)" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;target_{position}&space;=&space;target_{initPosition}&space;&plus;&space;(target_{velocity}*time)" title="target_{position} = target_{initPosition} + (target_{velocity}*time)" /></a>

We can then calculate a time-delay cause by changing position of the target

<a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;\Delta&space;t&space;=&space;\frac{2*target_{position}}{speedOfLight}" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;\Delta&space;t&space;=&space;\frac{2*target_{position}}{speedOfLight}" title="\Delta t = \frac{2*target_{position}}{speedOfLight}" /></a>

Transmit and Received signal can be model as 

<a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;Transmit&space;=&space;cos(2\pi(frequency_{radar}*t&space;&plus;&space;\frac{S_{chirp}*t^2}{2}))" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;Transmit&space;=&space;cos(2\pi(frequency_{radar}*t&space;&plus;&space;\frac{S_{chirp}*t^2}{2}))" title="Transmit = cos(2\pi(frequency_{radar}*t + \frac{S_{chirp}*t^2}{2}))" /></a>

and

<a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;Receive&space;=&space;cos(2\pi(frequency_{radar}*(t-\Delta&space;t)&space;&plus;&space;\frac{S_{chirp}*(t-\Delta&space;t)^2}{2}))" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;Receive&space;=&space;cos(2\pi(frequency_{radar}*(t-\Delta&space;t)&space;&plus;&space;\frac{S_{chirp}*(t-\Delta&space;t)^2}{2}))" title="Receive = cos(2\pi(frequency_{radar}*(t-\Delta t) + \frac{S_{chirp}*(t-\Delta t)^2}{2}))" /></a>

Finally, calculate Beat signal using element-wise multiplication between Transmit and Receive signal

<a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;BeatSignal&space;=&space;Transmit&space;.*&space;Receive" target="_blank"><img src="https://latex.codecogs.com/png.latex?\inline&space;BeatSignal&space;=&space;Transmit&space;.*&space;Receive" title="BeatSignal = Transmit .* Receive" /></a>

## Range FFT (1st FFT)
After BeatSignal has been simulated from above step, we can then apply Fast Fourier Transform on the signal. Output plot is shown below,

| <img src="images/RangeFromFirstFFT.png" width="1280" height="674" /> | 
|:--:| 
| *Actual target position is 130 m.* |

As can be seen, peak of the BeatSignal after FFT is at 131 m. while given target position at 130 m.

## 2D CFAR
Output of the signal after 2D FFT shown here,

| <img src="images/RangeFromSecondFFT.png" width="1280" height="674" /> | 
|:--:| 
| *Output of 2D FFT operation* |

