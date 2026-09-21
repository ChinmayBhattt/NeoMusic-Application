import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class SettingsState {
  final String audioQuality;
  final String equalizer;
  final bool offlineMode;
  final bool cellularStreaming;
  final String themeStyle;

  const SettingsState({
    required this.audioQuality,
    required this.equalizer,
    required this.offlineMode,
    required this.cellularStreaming,
    required this.themeStyle,
  });

  SettingsState copyWith({
    String? audioQuality,
    String? equalizer,
    bool? offlineMode,
    bool? cellularStreaming,
    String? themeStyle,
  }) {
    return SettingsState(
      audioQuality: audioQuality ?? this.audioQuality,
      equalizer: equalizer ?? this.equalizer,
      offlineMode: offlineMode ?? this.offlineMode,
      cellularStreaming: cellularStreaming ?? this.cellularStreaming,
      themeStyle: themeStyle ?? this.themeStyle,
    );
  }

  Map<String, dynamic> toJson() => {
        'audioQuality': audioQuality,
        'equalizer': equalizer,
        'offlineMode': offlineMode,
        'cellularStreaming': cellularStreaming,
        'themeStyle': themeStyle,
      };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
        audioQuality: json['audioQuality'] as String? ?? AppConstants.qualityHigh,
        equalizer: json['equalizer'] as String? ?? 'Cyber Electronic',
        offlineMode: json['offlineMode'] as bool? ?? false,
        cellularStreaming: json['cellularStreaming'] as bool? ?? true,
        themeStyle: json['themeStyle'] as String? ?? 'Dark Modern',
      );
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState.fromJson(StorageService.localStorage.getSettings());
  }

  Future<void> setAudioQuality(String quality) async {
    state = state.copyWith(audioQuality: quality);
    await StorageService.localStorage.saveSettings(state.toJson());
  }

  Future<void> setEqualizer(String eq) async {
    state = state.copyWith(equalizer: eq);
    await StorageService.localStorage.saveSettings(state.toJson());
  }

  Future<void> setOfflineMode(bool offline) async {
    state = state.copyWith(offlineMode: offline);
    await StorageService.localStorage.saveSettings(state.toJson());
  }

  Future<void> setCellularStreaming(bool cellular) async {
    state = state.copyWith(cellularStreaming: cellular);
    await StorageService.localStorage.saveSettings(state.toJson());
  }

  Future<void> setThemeStyle(String theme) async {
    state = state.copyWith(themeStyle: theme);
    await StorageService.localStorage.saveSettings(state.toJson());
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
