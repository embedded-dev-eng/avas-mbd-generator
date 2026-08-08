% Script genere automatiquement par generate_model.py
% Ne pas editer a la main : modifier data/functions.xlsx et data/parameters.xml
% puis relancer generate_model.py

modelName = 'AVAS_ElectricVehicle';
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
new_system(modelName);
open_system(modelName);

%% --- Data dictionary : parametres issus de parameters.xml ---
assignin('base', 'F01_SamplingRate_Hz', 100);
assignin('base', 'F01_SpeedRange_kmh_min', 0);
assignin('base', 'F01_SpeedRange_kmh_max', 130);
assignin('base', 'F02_ActivationSpeed_kmh_min', 0);
assignin('base', 'F02_ActivationSpeed_kmh_max', 20);
assignin('base', 'F02_FrequencyBand_Hz_min', 160);
assignin('base', 'F02_FrequencyBand_Hz_max', 5000);
assignin('base', 'F02_ReverseGearTone_Hz', 440);
assignin('base', 'F03_SoundLevel_dB_min', 56);
assignin('base', 'F03_SoundLevel_dB_max', 75);
assignin('base', 'F03_RampUpSpeed_kmh_start', 0);
assignin('base', 'F03_RampUpSpeed_kmh_end', 20);
assignin('base', 'F04_OutputImpedance_ohm', 4);
assignin('base', 'F04_MaxPower_W', 30);

%% --- Creation des blocs Subsystem (un par fonction) ---
add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/SpeedSensorInterface'], 'Position', '[30 30 170 110]');
delete_block([modelName '/SpeedSensorInterface/In1']);
delete_block([modelName '/SpeedSensorInterface/Out1']);
try; delete_line(find_system([modelName '/SpeedSensorInterface'], 'FindAll', 'on', 'SearchDepth', 1, 'Type', 'line')); catch; end
add_block('simulink/Sources/In1', [modelName '/SpeedSensorInterface/VehicleSpeed_raw'], 'Position', '[30 30 60 50]');
add_block('simulink/Sinks/Out1', [modelName '/SpeedSensorInterface/VehicleSpeed_kmh'], 'Position', '[300 30 330 50]');
add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/SoundGenerator'], 'Position', '[250 30 390 110]');
delete_block([modelName '/SoundGenerator/In1']);
delete_block([modelName '/SoundGenerator/Out1']);
try; delete_line(find_system([modelName '/SoundGenerator'], 'FindAll', 'on', 'SearchDepth', 1, 'Type', 'line')); catch; end
add_block('simulink/Sources/In1', [modelName '/SoundGenerator/VehicleSpeed_kmh'], 'Position', '[30 30 60 50]');
add_block('simulink/Sinks/Out1', [modelName '/SoundGenerator/AudioSignal_raw'], 'Position', '[300 30 330 50]');
add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/VolumeControl'], 'Position', '[470 30 610 110]');
delete_block([modelName '/VolumeControl/In1']);
delete_block([modelName '/VolumeControl/Out1']);
try; delete_line(find_system([modelName '/VolumeControl'], 'FindAll', 'on', 'SearchDepth', 1, 'Type', 'line')); catch; end
add_block('simulink/Sources/In1', [modelName '/VolumeControl/AudioSignal_raw'], 'Position', '[30 30 60 50]');
add_block('simulink/Sources/In1', [modelName '/VolumeControl/VehicleSpeed_kmh'], 'Position', '[30 90 60 110]');
add_block('simulink/Sinks/Out1', [modelName '/VolumeControl/AudioSignal_scaled'], 'Position', '[300 30 330 50]');
add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/SpeakerOutputDriver'], 'Position', '[690 30 830 110]');
delete_block([modelName '/SpeakerOutputDriver/In1']);
delete_block([modelName '/SpeakerOutputDriver/Out1']);
try; delete_line(find_system([modelName '/SpeakerOutputDriver'], 'FindAll', 'on', 'SearchDepth', 1, 'Type', 'line')); catch; end
add_block('simulink/Sources/In1', [modelName '/SpeakerOutputDriver/AudioSignal_scaled'], 'Position', '[30 30 60 50]');
add_block('simulink/Sinks/Out1', [modelName '/SpeakerOutputDriver/SpeakerCommand'], 'Position', '[300 30 330 50]');

%% --- Logique interne : SoundGenerator (F02) ---
% Lookup Table 1-D : convertit VehicleSpeed_kmh en frequence audio (Hz),
% pilotee par les seuils issus de parameters.xml (aucune valeur en dur).
add_block('simulink/Lookup Tables/Lookup Table', [modelName '/SoundGenerator/FrequencyMapping'], 'Position', '[150 65 230 95]');
set_param([modelName '/SoundGenerator/FrequencyMapping'], 'InputValues', '[F02_ActivationSpeed_kmh_min F02_ActivationSpeed_kmh_max]', 'Table', '[F02_FrequencyBand_Hz_min F02_FrequencyBand_Hz_max]');
add_line([modelName '/SoundGenerator'], 'VehicleSpeed_kmh/1', 'FrequencyMapping/1', 'autorouting', 'on');
add_line([modelName '/SoundGenerator'], 'FrequencyMapping/1', 'AudioSignal_raw/1', 'autorouting', 'on');

%% --- Interconnexion des blocs selon NextFunctionID ---
add_line(modelName, 'SpeedSensorInterface/1', 'SoundGenerator/1', 'autorouting', 'on');
add_line(modelName, 'SoundGenerator/1', 'VolumeControl/1', 'autorouting', 'on');
add_line(modelName, 'VolumeControl/1', 'SpeakerOutputDriver/1', 'autorouting', 'on');

Simulink.BlockDiagram.arrangeSystem(modelName);
save_system(modelName, fullfile(fileparts(mfilename('fullpath')), 'AVAS_ElectricVehicle.slx'));
disp('Modele AVAS_ElectricVehicle.slx genere avec succes.');