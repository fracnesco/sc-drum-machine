// panels/sdgratchet.scd - what the ratchet's window shows (SynthVoiceWindow).
// The roll pane works out the def's own arithmetic: n clicks, each gap r times the one
// before (last / first = 2 ** (-5 * curve)), each click fade = r ** (0.6 * curve) of the last.
(
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var roll = { |p|
	var n = p[\sdgcount].round.asInteger.clip(1, 32), c = p[\sdgcurve].clip(-1, 1), len = p[\sdglen].clip(0.01, 2);
	var gaps = (n - 1).max(1), r = 2 ** (c.neg * 5 / (gaps - 1).max(1));
	var total = if((r - 1).abs < 1e-6) { gaps } { (1 - (r ** gaps)) / (1 - r) };
	var first = len / total, fade = r ** (c * 0.6), step = p[\sdgwalk].clip(-48, 48) / gaps, t = 0;
	n.collect { |k| var e = (t: t, level: (fade ** k).clip(0.05, 1), pitch: (k * step) + (sin(k * 12.9898 + 0.7) * p[\sdgcolor] * 12));
		t = t + (first * (r ** k)); e }
};
(
	colour: \aqua, drum: true,
	hint: "clicks and length set the roll; curve bends it into a bouncing ball (above 0) or a slowdown (below)",
	panes: [
		(type: \hits, w: 1.6, pitched: true, title: "the roll", len: { |p| (p[\sdglen] + p[\sdgdecay]) * 1.05 },
			list: roll,
			range: { |p| var m = (p[\sdgwalk].abs + (p[\sdgcolor] * 12)).max(6).ceil; [m.neg, m] },
			readout: { |p| "% clicks in % · walks % st".format(p[\sdgcount].round.asInteger, SynthVoicePanes.format(p[\sdglen], "s"), p[\sdgwalk].round(0.1)) }),
		(type: \filter, mode: \bp, w: 1, title: "each click pings", cut: { |p| p[\sdgfreq] }, fund: nil,
			q: { |p| (p[\sdgfreq] * pi * p[\sdgdecay]).clip(1, 400).explin(1, 400, 0, 1) },
			readout: { |p| "% · rings %".format(hz.(p[\sdgfreq]), SynthVoicePanes.format(p[\sdgdecay], "s")) }),
		(type: \wave, w: 0.7, title: "crush", cycles: 2,
			func: { |ph, p| var b = p[\sdgbits].clip(0, 1), lv = 2 ** (15 - (b * 13)), hold = (2 ** (b * 4)) / 64;
				var s = sin((ph - (ph % hold.max(1e-4))) * 2pi); blend(sin(ph * 2pi), (s * lv).round / lv, (b * 10).min(1)) },
			ref: { |ph| sin(ph * 2pi) }, refLabel: "clean", label: "crushed",
			readout: { |p| if(p[\sdgbits] < 0.005) { "off" } { "% bits".format((15 - (p[\sdgbits] * 13)).round(0.1)) } })
	],
	macros: [
		(name: "brightness", text: "pitch and noise", targets: [[\sdgfreq, 0.3], [\sdgtone, 0.4]]),
		(name: "timbre", text: "scatter and crush", targets: [[\sdgcolor, 0.3], [\sdgbits, 0.35]]),
		(name: "time", text: "roll length and ring", targets: [[\sdglen, 0.4], [\sdgdecay, 0.3]]),
		(name: "movement", text: "bend, walk and spread", targets: [[\sdgcurve, 0.4], [\sdgwalk, 0.25], [\sdgspread, 0.5]])
	],
	cards: [
		(title: "roll", coloured: true, knobs: [
			(key: \sdgcount, label: "clicks", size: \big, steps: [1, 2, 3, 4, 5, 6, 8, 10, 12, 14, 16, 20, 24, 32], sub: "in the roll"),
			(key: \sdglen, label: "length", size: \big, spec: ControlSpec(0.01, 2, \exp, 0, 0.5, "s"), sub: "first to last"),
			(key: \sdgcurve, label: "curve", spec: ControlSpec(-1, 1, \lin, 0, 0), sub: "slow ↔ bounce")]),
		(title: "pitch", knobs: [
			(key: \sdgwalk, label: "walk", spec: ControlSpec(-48, 48, \lin, 0, 0, "st"), sub: "over the roll"),
			(key: \sdgcolor, label: "scatter", spec: ControlSpec(0, 1, \amp), box: \pct, sub: "per click")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "ping ↔ tick")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(60, 12000, \exp, 0, 1400, "Hz"), sub: "first click", vary: false),
			(key: \sdgdecay, label: "decay", spec: ControlSpec(0.002, 0.5, \exp, 0, 0.035, "s"), sub: "each ring"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgbits, label: "crush", spec: ControlSpec(0, 1), box: \pct, floor: "off", sub: "bits and rate"),
		(key: \sdgspread, label: "spread", spec: ControlSpec(0, 1), box: \pct, sub: "left, right")])
)
)
