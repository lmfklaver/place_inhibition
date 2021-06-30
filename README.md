place_inhibition

For a pipeline of preprocessing and analysis steps to take please see either
* PF_Analysis_VRnoVR      (Virtual Reality screens on versus screens off)
* PF_Analysis_AllSetups   (Virtual Reality, Linear Track, Open Field)

Each script is arranged as followed:
1) Run preprocessing steps - only to be done one time
2) Each section of the script may be run independently - after running the section labeled 'define and load mat files' for that specific section. 

Data organization:
* Each recording folder should have a text document named [basename '_RecordingInfo.txt'] containing start and stop times of sleep and experimental tasks, channels with spikes, max ripple channel by eye, important notes, depth of electrode, date, etc.
* Each recording folder should have a subfolder called "Videos_CSVs": This folder should contain all videos taken during the experiment, and all csvs outputted from bonsai.
  * Within this folder, there should be two additional folders. One named: [basename '_VideoOpenField'] and one named: [basename '_VideoLinearTrack]. These folders should contain the position prediction output from DLC (csv file) and the original video (.mp4). ONLY one of each file type should be kept in each of these folders.

		

