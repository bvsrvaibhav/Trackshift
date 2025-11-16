# REFLEX-RF's Trackshift
#REFLEX-RF's Trackshift: Low-Latency FPGA AGC & Symbol Synchronization for High-Speed Telemetry

A high-performance FPGA signal-processing chain inspired by Formula 1 real-time telemetry systems.

 Project Overview

This project implements a complete low-latency digital receiver chain on the Zynq-7000 FPGA, featuring:

Automatic Gain Control (AGC)

Symbol Synchronization using ZCTED

Piecewise Parabolic Interpolator (PPI)

Loop Filter + NCO for timing correction

16-QAM constellation capture and analysis

The design is optimized for scenarios where the wireless channel changes extremely fast, similar to Formula 1 telemetry, where a car moves at 300+ km/h, passes through buildings, bridges, and corners, and still must transmit stable real-time data to the pitwall and FIA.

📡 Why Formula 1?

F1 cars transmit more than 1,000 sensor channels including:

Power unit metrics

Tire temperatures

Brake energy

ERS deployment

GPS position, acceleration, and chassis data

The signal must remain reliable even in urban circuits like Monaco, Baku, Singapore, etc., where:

Line-of-sight breaks

Multipath reflections occur

Signal suddenly drops or spikes

To survive this, F1 systems rely heavily on:

Fast AGC

Robust symbol timing recovery

Adaptive equalization

Diversity receivers

This project recreates the FPGA portion of that pipeline.

⚙️ Core Components
🔧 1. Automatic Gain Control (AGC)

Maintains constant signal amplitude despite fading.

Prevents ADC clipping and underflow.

Uses power estimation + gain adjustment loop.

Achieved ~50 ns response time.

Directly reduces symbol errors in dynamic conditions.

Files:
AGC_Trackshift/
• main.v
• error_detector.v
• calculator.v
• loop.v
• multiplier.v
• Block_Diagram.png
• Result.png

🔧 2. Symbol Synchronization (ZCTED)

Implements Zero-Crossing Timing Error Detector.

Corrects sampling offset due to Doppler + channel distortion.

Uses Piecewise Parabolic Interpolator for fractional delay.

Loop Filter + NCO constantly align the sampling clock.

Essential for clear constellation and low BER.

Files:
ZCTED_Trackshift/
• ZCTED.v
• Piecewise_Parabolic_Interpolator.v
• NCO.v
• PI_Loop_Filter.v
• testbench_zcted.v
• Result1.png, Result2.png

🎯 3. Performance

Based on captured FPGA output:

Metric	Result
Modulation	16-QAM
Estimated SNR	~7.4 dB
Pre-FEC BER	3×10⁻⁴
Constellation	Clean & stable

This performance is very strong for a prototype and fully correctable with standard FEC (LDPC / convolutional).

🧠 System Block Diagram

(Include your Block_Diagram.png here)

🛠️ How to Run

Synthesize and implement in Vivado (Zynq-7000).

Run the testbenches:

tb_agc123.v for AGC

testbench_zcted.v for ZCTED

Capture I/Q logs from the FPGA.

Use MATLAB scripts to plot:

Constellation

Eye diagram

SNR/BER estimation

🏁 Future Work

Add RRC matched filter for better SNR & ISI reduction

Integrate FEC (LDPC / Convolutional)

Implement adaptive LMS/DFE equalizer

Add diversity combining similar to FIA’s trackside architecture

Test with higher-order modulations (64-QAM / 256-QAM)

Full telemetry pipeline: RF → AGC → Sync → Equalizer → Demod → Analytics
