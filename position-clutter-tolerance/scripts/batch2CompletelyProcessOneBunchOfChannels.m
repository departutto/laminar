 destination    = 'C:\Users\u0062274\Desktop\test\';
 experimentFile = [destination '139-14062016-clutter invariance-rat-68540-area-V1-depth 1-session-4.mat'];
 nevFile        = [destination 'Events.nev'];
 
 timestampsFile = [destination 'channels_01_08.dat.mat'];
 kwikFile       = [destination 'channels_01_08.kwik'];
 resultsFile    = [destination 'res_channels_01_08.mat'];
 computePSTHs4OneBunchOfChannels(experimentFile, timestampsFile, nevFile, kwikFile, resultsFile);
 clear timestampsFile kwikFile resultsFile;
 
 timestampsFile = [destination 'channels_06_13.dat.mat'];
 kwikFile       = [destination 'channels_06_13.kwik'];
 resultsFile    = [destination 'res_channels_06_13.mat'];
 computePSTHs4OneBunchOfChannels(experimentFile, timestampsFile, nevFile, kwikFile, resultsFile);
 clear timestampsFile kwikFile resultsFile;
 
 timestampsFile = [destination 'channels_11_18.dat.mat'];
 kwikFile       = [destination 'channels_11_18.kwik'];
 resultsFile    = [destination 'res_channels_11_18.mat'];
 computePSTHs4OneBunchOfChannels(experimentFile, timestampsFile, nevFile, kwikFile, resultsFile);
 clear timestampsFile kwikFile resultsFile;
 
 timestampsFile = [destination 'channels_16_23.dat.mat'];
 kwikFile       = [destination 'channels_16_23.kwik'];
 resultsFile    = [destination 'res_channels_16_23.mat'];
 computePSTHs4OneBunchOfChannels(experimentFile, timestampsFile, nevFile, kwikFile, resultsFile);
 clear timestampsFile kwikFile resultsFile;
 
 timestampsFile = [destination 'channels_21_28.dat.mat'];
 kwikFile       = [destination 'channels_21_28.kwik'];
 resultsFile    = [destination 'res_channels_21_28.mat'];
 computePSTHs4OneBunchOfChannels(experimentFile, timestampsFile, nevFile, kwikFile, resultsFile);
 clear timestampsFile kwikFile resultsFile;
 
 timestampsFile = [destination 'channels_26_32.dat.mat'];
 kwikFile       = [destination 'channels_26_32.kwik'];
 resultsFile    = [destination 'res_channels_26_32.mat'];
 computePSTHs4OneBunchOfChannels(experimentFile, timestampsFile, nevFile, kwikFile, resultsFile);
 clear timestampsFile kwikFile resultsFile;
 
 clear destination experimentFile nevFile;
 