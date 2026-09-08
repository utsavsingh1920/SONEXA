import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../player/player_controller.dart';
import '../player/player_scope.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  static const Color _purple = Color(0xFF9B6BFF);
  static const Color _darkBackground = Color(0xFF09070F);
  static const Color _darkCard = Color(0xFF15111F);

  // ============================================================
  // PLAYER / EQUALIZER
  // ============================================================

  late AndroidEqualizer _equalizer;

  bool _controllerReady = false;

  // ============================================================
  // EQUALIZER STATE
  // ============================================================

  AndroidEqualizerParameters? _parameters;

  bool _isLoading = true;
  bool _isEnabled = true;
  bool _isApplying = false;

  String _selectedPreset = 'Normal';

  List<double> _values = <double>[];

  static const List<String> _presetNames = <String>[
    'Normal',
    'Rock',
    'Pop',
    'Jazz',
    'Classical',
    'Bass Boost',
  ];

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();
  }

  // ============================================================
  // PLAYER SCOPE
  // ============================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_controllerReady) {
      return;
    }

    final PlayerController controller = PlayerScope.of(context);

    _equalizer = controller.equalizer;
    _controllerReady = true;

    _loadEqualizer();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    super.dispose();
  }

  // ============================================================
  // LOAD EQUALIZER
  // ============================================================

  Future<void> _loadEqualizer() async {
    try {
      final AndroidEqualizerParameters parameters =
          await _equalizer.parameters;

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      final bool savedEnabled =
          prefs.getBool(
                'sonexa_equalizer_enabled',
              ) ??
              true;

      final String savedPreset =
          prefs.getString(
                'sonexa_equalizer_preset',
              ) ??
              'Normal';

      final List<String>? savedValues =
          prefs.getStringList(
        'sonexa_equalizer_values',
      );

      final List<double> values = <double>[];

      for (
        int i = 0;
        i < parameters.bands.length;
        i++
      ) {
        double value;

        if (
          savedValues != null &&
          i < savedValues.length
        ) {
          value =
              double.tryParse(
                savedValues[i],
              ) ??
              0.5;
        } else {
          final double gain =
              parameters.bands[i].gain;

          value = _gainToSlider(
            gain,
            parameters.minDecibels,
            parameters.maxDecibels,
          );
        }

        values.add(
          value.clamp(0.0, 1.0),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _parameters = parameters;
        _values = values;
        _isEnabled = savedEnabled;

        _selectedPreset =
            _presetNames.contains(
              savedPreset,
            )
                ? savedPreset
                : 'Normal';

        _isLoading = false;
      });

      await _equalizer.setEnabled(
        savedEnabled,
      );
    } catch (e) {
      debugPrint(
        'SONEXA Equalizer Load Error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Equalizer Android device par available nahi hai.',
      );
    }
  }

  // ============================================================
  // GAIN -> SLIDER
  // ============================================================

  double _gainToSlider(
    double gain,
    double minGain,
    double maxGain,
  ) {
    if (maxGain <= minGain) {
      return 0.5;
    }

    return (
      (gain - minGain) /
      (maxGain - minGain)
    ).clamp(0.0, 1.0);
  }

  // ============================================================
  // SLIDER -> GAIN
  // ============================================================

  double _sliderToGain(
    double value,
    double minGain,
    double maxGain,
  ) {
    return minGain +
        (
          (maxGain - minGain) *
          value
        );
  }

  // ============================================================
  // ENABLE / DISABLE EQUALIZER
  // ============================================================

  Future<void> _toggleEqualizer(
    bool value,
  ) async {
    setState(() {
      _isEnabled = value;
    });

    try {
      await _equalizer.setEnabled(
        value,
      );

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        'sonexa_equalizer_enabled',
        value,
      );
    } catch (e) {
      debugPrint(
        'SONEXA Equalizer Toggle Error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isEnabled = !value;
      });

      _showMessage(
        'Equalizer enable/disable nahi ho saka.',
      );
    }
  }

  // ============================================================
  // SET INDIVIDUAL BAND
  // ============================================================

  Future<void> _setBand(
    int index,
    double value,
  ) async {
    final AndroidEqualizerParameters? parameters =
        _parameters;

    if (
      parameters == null ||
      index < 0 ||
      index >= parameters.bands.length
    ) {
      return;
    }

    setState(() {
      _values[index] = value;
      _selectedPreset = 'Custom';
    });

    final AndroidEqualizerBand band =
        parameters.bands[index];

    final double gain = _sliderToGain(
      value,
      parameters.minDecibels,
      parameters.maxDecibels,
    );

    try {
      await band.setGain(gain);

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'sonexa_equalizer_preset',
        'Custom',
      );

      await _saveValues();
    } catch (e) {
      debugPrint(
        'SONEXA Equalizer Band Error: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Band value apply nahi ho saki.',
      );
    }
  }

  // ============================================================
  // APPLY PRESET
  // ============================================================

  Future<void> _applyPreset(
    String preset,
  ) async {
    final AndroidEqualizerParameters? parameters =
        _parameters;

    if (
      parameters == null ||
      parameters.bands.isEmpty
    ) {
      return;
    }

    final int bandCount =
        parameters.bands.length;

    List<double> presetValues =
        List<double>.filled(
      bandCount,
      0.5,
    );

    switch (preset) {
      case 'Normal':
        presetValues =
            List<double>.filled(
          bandCount,
          0.5,
        );
        break;

      case 'Rock':
        presetValues =
            _createPresetValues(
          bandCount,
          <double>[
            0.76,
            0.68,
            0.56,
            0.70,
            0.78,
          ],
        );
        break;

      case 'Pop':
        presetValues =
            _createPresetValues(
          bandCount,
          <double>[
            0.60,
            0.46,
            0.64,
            0.76,
            0.68,
          ],
        );
        break;

      case 'Jazz':
        presetValues =
            _createPresetValues(
          bandCount,
          <double>[
            0.52,
            0.60,
            0.58,
            0.66,
            0.58,
          ],
        );
        break;

      case 'Classical':
        presetValues =
            _createPresetValues(
          bandCount,
          <double>[
            0.46,
            0.52,
            0.58,
            0.66,
            0.72,
          ],
        );
        break;

      case 'Bass Boost':
        presetValues =
            _createPresetValues(
          bandCount,
          <double>[
            0.92,
            0.82,
            0.66,
            0.54,
            0.50,
          ],
        );
        break;

      default:
        presetValues =
            List<double>.filled(
          bandCount,
          0.5,
        );
    }

    setState(() {
      _isApplying = true;
      _selectedPreset = preset;
      _values = presetValues;
    });

    try {
      for (
        int i = 0;
        i < bandCount;
        i++
      ) {
        final AndroidEqualizerBand band =
            parameters.bands[i];

        final double gain =
            _sliderToGain(
          presetValues[i],
          parameters.minDecibels,
          parameters.maxDecibels,
        );

        await band.setGain(gain);
      }

      await _equalizer.setEnabled(
        true,
      );

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'sonexa_equalizer_preset',
        preset,
      );

      await prefs.setBool(
        'sonexa_equalizer_enabled',
        true,
      );

      await _saveValues();

      if (!mounted) {
        return;
      }

      setState(() {
        _isEnabled = true;
        _isApplying = false;
      });
    } catch (e) {
      debugPrint(
        'SONEXA Equalizer Preset Error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isApplying = false;
      });

      _showMessage(
        'Preset apply nahi ho saka.',
      );
    }
  }

  // ============================================================
  // CREATE PRESET VALUES
  // ============================================================

  List<double> _createPresetValues(
    int bandCount,
    List<double> baseValues,
  ) {
    if (bandCount <= 0) {
      return <double>[];
    }

    if (bandCount == 1) {
      return <double>[
        baseValues[
          baseValues.length ~/ 2
        ],
      ];
    }

    if (bandCount == baseValues.length) {
      return List<double>.from(
        baseValues,
      );
    }

    final List<double> result =
        <double>[];

    for (
      int i = 0;
      i < bandCount;
      i++
    ) {
      final double position =
          i / (bandCount - 1);

      final double scaled =
          position *
          (baseValues.length - 1);

      final int left =
          scaled.floor();

      final int right =
          scaled.ceil().clamp(
            0,
            baseValues.length - 1,
          );

      final double fraction =
          scaled - left;

      final double value =
          baseValues[left] +
          (
            (
              baseValues[right] -
              baseValues[left]
            ) *
            fraction
          );

      result.add(
        value.clamp(0.0, 1.0),
      );
    }

    return result;
  }

  // ============================================================
  // SAVE VALUES
  // ============================================================

  Future<void> _saveValues() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      'sonexa_equalizer_values',
      _values
          .map(
            (double value) =>
                value.toString(),
          )
          .toList(),
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void> _resetEqualizer() async {
    await _applyPreset(
      'Normal',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor: _purple,
        ),
      );
  }

  // ============================================================
  // FREQUENCY LABEL
  // ============================================================

  String _frequencyLabel(
    double frequency,
  ) {
    if (frequency >= 1000) {
      final double khz =
          frequency / 1000;

      if (khz >= 10) {
        return '${khz.toStringAsFixed(0)}k';
      }

      return '${khz.toStringAsFixed(1)}k';
    }

    return frequency.toStringAsFixed(
      0,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final ThemeData theme =
        Theme.of(context);

    // IMPORTANT:
    // Theme sirf Appearance screen se aayega.
    // Equalizer khud Dark/Light/System select nahi karta.
    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color background = isDark
        ? _darkBackground
        : theme.scaffoldBackgroundColor;

    final Color cardColor = isDark
        ? _darkCard
        : theme.colorScheme.surface;

    return Scaffold(
      backgroundColor:
          background,

      appBar: AppBar(
        backgroundColor:
            background,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Equalizer',
          style: TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: _purple,
              ),
            )
          : _parameters == null
              ? _buildUnavailableState(
                  theme,
                )
              : SafeArea(
                  child: ListView(
                    physics:
                        const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      8,
                      18,
                      32,
                    ),
                    children: <Widget>[
                      _buildHeaderCard(
                        theme,
                        cardColor,
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      _buildPresetSection(
                        theme,
                        cardColor,
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      _buildEqualizerSection(
                        theme,
                        cardColor,
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      _buildResetCard(
                        theme,
                        cardColor,
                      ),
                    ],
                  ),
                ),
    );
  }

  // ============================================================
  // HEADER CARD
  // ============================================================

  Widget _buildHeaderCard(
    ThemeData theme,
    Color cardColor,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: _purple.withValues(
            alpha:
                theme.brightness ==
                        Brightness.dark
                    ? 0.10
                    : 0.08,
          ),
        ),
        boxShadow:
            theme.brightness ==
                    Brightness.dark
                ? <BoxShadow>[
                    BoxShadow(
                      color:
                          Colors.black
                              .withValues(
                        alpha: 0.20,
                      ),
                      blurRadius: 20,
                      offset:
                          const Offset(
                        0,
                        8,
                      ),
                    ),
                  ]
                : null,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: <Color>[
                  Color(
                    0xFFB77CFF,
                  ),
                  Color(
                    0xFF6D28D9,
                  ),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                      _purple.withValues(
                    alpha: 0.25,
                  ),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.equalizer_rounded,
              color:
                  Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: <Widget>[
                const Text(
                  'SONEXA Equalizer',
                  style:
                      TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Tune the sound of your music',
                  style:
                      TextStyle(
                    fontSize: 12,
                    color: theme
                        .colorScheme
                        .onSurface
                        .withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: _isEnabled,
            activeTrackColor:
                _purple,
            onChanged:
                _toggleEqualizer,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRESET SECTION
  // ============================================================

  Widget _buildPresetSection(
    ThemeData theme,
    Color cardColor,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.tune_rounded,
                color: _purple,
              ),

              const SizedBox(
                width: 9,
              ),

              const Text(
                'Presets',
                style:
                    TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const Spacer(),

              if (_isApplying)
                const SizedBox(
                  width: 17,
                  height: 17,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _purple,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Wrap(
            spacing: 9,
            runSpacing: 9,
            children:
                _presetNames.map(
              (
                String preset,
              ) {
                final bool selected =
                    _selectedPreset ==
                        preset;

                return GestureDetector(
                  onTap:
                      _isApplying
                          ? null
                          : () =>
                              _applyPreset(
                                preset,
                              ),
                  child:
                      AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds:
                          180,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? _purple
                          : theme
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(
                            alpha: 0.55,
                          ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                      border:
                          Border.all(
                        color: selected
                            ? _purple
                            : theme
                                .colorScheme
                                .onSurface
                                .withValues(
                              alpha: 0.06,
                            ),
                      ),
                    ),
                    child: Text(
                      preset,
                      style:
                          TextStyle(
                        color: selected
                            ? Colors
                                .white
                            : theme
                                .colorScheme
                                .onSurface
                                .withValues(
                              alpha: 0.75,
                            ),
                        fontSize: 12,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EQUALIZER SECTION
  // ============================================================

  Widget _buildEqualizerSection(
    ThemeData theme,
    Color cardColor,
  ) {
    final AndroidEqualizerParameters
        parameters =
        _parameters!;

    final List<AndroidEqualizerBand>
        bands =
        parameters.bands;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        15,
        18,
        15,
        18,
      ),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.graphic_eq_rounded,
                color: _purple,
              ),

              const SizedBox(
                width: 9,
              ),

              const Text(
                'Frequency Bands',
                style:
                    TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const Spacer(),

              Text(
                _selectedPreset,
                style:
                    const TextStyle(
                  color: _purple,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          SizedBox(
            height: 315,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children:
                  List<Widget>.generate(
                bands.length,
                (
                  int index,
                ) {
                  final AndroidEqualizerBand
                      band =
                      bands[index];

                  final double value =
                      index <
                              _values.length
                          ? _values[
                              index]
                          : 0.5;

                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 2,
                      ),
                      child: Column(
                        children:
                            <Widget>[
                          Text(
                            '${_gainForDisplay(index)} dB',
                            style:
                                TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color: theme
                                  .colorScheme
                                  .onSurface
                                  .withValues(
                                alpha: 0.60,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Expanded(
                            child:
                                RotatedBox(
                              quarterTurns:
                                  3,
                              child:
                                  SliderTheme(
                                data:
                                    SliderTheme.of(
                                  context,
                                ).copyWith(
                                  activeTrackColor:
                                      _purple,
                                  inactiveTrackColor:
                                      theme
                                          .colorScheme
                                          .onSurface
                                          .withValues(
                                    alpha:
                                        0.10,
                                  ),
                                  thumbColor:
                                      Colors
                                          .white,
                                  overlayColor:
                                      _purple
                                          .withValues(
                                    alpha:
                                        0.12,
                                  ),
                                  trackHeight:
                                      4,
                                  thumbShape:
                                      const RoundSliderThumbShape(
                                    enabledThumbRadius:
                                        7,
                                  ),
                                  overlayShape:
                                      const RoundSliderOverlayShape(
                                    overlayRadius:
                                        16,
                                  ),
                                ),
                                child:
                                    Slider(
                                  value:
                                      value,
                                  min: 0,
                                  max: 1,
                                  onChanged:
                                      !_isEnabled ||
                                              _isApplying
                                          ? null
                                          : (
                                              double
                                                  newValue,
                                            ) {
                                              _setBand(
                                                index,
                                                newValue,
                                              );
                                            },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            _frequencyLabel(
                              band.centerFrequency,
                            ),
                            style:
                                TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color: theme
                                  .colorScheme
                                  .onSurface
                                  .withValues(
                                alpha: 0.70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Row(
            children: <Widget>[
              Text(
                '${parameters.minDecibels.toStringAsFixed(0)} dB',
                style:
                    TextStyle(
                  fontSize: 10,
                  color: theme
                      .colorScheme
                      .onSurface
                      .withValues(
                    alpha: 0.45,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                '0 dB',
                style:
                    TextStyle(
                  fontSize: 10,
                  color: theme
                      .colorScheme
                      .onSurface
                      .withValues(
                    alpha: 0.45,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                '+${parameters.maxDecibels.toStringAsFixed(0)} dB',
                style:
                    TextStyle(
                  fontSize: 10,
                  color: theme
                      .colorScheme
                      .onSurface
                      .withValues(
                    alpha: 0.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GAIN DISPLAY
  // ============================================================

  String _gainForDisplay(
    int index,
  ) {
    if (
      _parameters == null ||
      index < 0 ||
      index >= _values.length
    ) {
      return '0.0';
    }

    final AndroidEqualizerParameters
        parameters =
        _parameters!;

    final double gain =
        _sliderToGain(
      _values[index],
      parameters.minDecibels,
      parameters.maxDecibels,
    );

    if (gain > 0) {
      return '+${gain.toStringAsFixed(1)}';
    }

    return gain.toStringAsFixed(
      1,
    );
  }

  // ============================================================
  // RESET CARD
  // ============================================================

  Widget _buildResetCard(
    ThemeData theme,
    Color cardColor,
  ) {
    return Material(
      color: cardColor,
      borderRadius:
          BorderRadius.circular(24),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(24),
        onTap:
            _isApplying
                ? null
                : _resetEqualizer,
        child: Padding(
          padding:
              const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color: Colors.red
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .restart_alt_rounded,
                  color:
                      Colors.redAccent,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: <Widget>[
                    Text(
                      'Reset Equalizer',
                      style:
                          TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Return all bands to Normal',
                      style:
                          TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons
                    .chevron_right_rounded,
                color: theme
                    .colorScheme
                    .onSurface
                    .withValues(
                  alpha: 0.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UNAVAILABLE STATE
  // ============================================================

  Widget _buildUnavailableState(
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 84,
              height: 84,
              decoration:
                  BoxDecoration(
                color:
                    _purple.withValues(
                  alpha: 0.12,
                ),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .equalizer_rounded,
                size: 42,
                color: _purple,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            const Text(
              'Equalizer unavailable',
              style:
                  TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Android device par audio equalizer initialize nahi ho saka.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color: theme
                    .colorScheme
                    .onSurface
                    .withValues(
                  alpha: 0.55,
                ),
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });

                _loadEqualizer();
              },
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    _purple,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}