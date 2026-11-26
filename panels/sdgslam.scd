// panels/sdgslam.scd - what the slam's window shows (SynthVoiceWindow).
// The layers pane draws the body through the def's drive, so a hard drive shows it squashed flat.
(
var fall = { |decay| { |t| exp(t.neg * 6.9 / decay.max(0.001)) } };
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var seg = { |u, c| u = u.clip(0, 1); if(c.abs < 0.001) { u } { (1 - exp(c * u)) / (1 - exp(c)) } };
var rel = { |p| (p[\sdgdecay] * 0.15).clip(0.008, 0.06) };
var ring = { |p| 0.06 + (p[\sdgmetal] * 0.6) };
var bodyEnv = { |t, p| var d = p[\sdgdecay], r = rel.(p);
	case { t < 0.0005 } { t / 0.0005 } { t < (d + 0.0005) } { 1 - (0.15 * seg.((t - 0.0005) / d, -1)) } { 0.85 * (1 - seg.((t - d - 0.0005) / r, -4)) } };
var drive = { |p| p[\sdgdrive].linexp(0, 1, 1.2, 24) };
var dive = { |t, p| var top = p[\sdgpunch];
	if(t < 0.006) { top + 24 - (24 * seg.(t / 0.006, -4)) } { top * (1 - (t - 0.006 / p[\sdgbend].max(0.005)).clip(0, 1)) } };
(
	colour: \orchid, drum: true,
	hint: "a sine that dives from far above and lands on tune; drive squashes it flat, clang and noise ride on top",
	links: (sdgdecay: [\sdgnoise]),
	panes: [
		(type: \pitch, w: 1.0, title: "the dive", len: { |p| (p[\sdgbend] * 1.4 + 0.02).clip(0.05, 2.2) }, func: dive,
			range: { |p| [-2, (p[\sdgpunch] * 1.15).max(6)] }, zero: "lands",
			readout: { |p| "from +% st to % in %".format(p[\sdgpunch].round(0.1), hz.(p[\sdgfreq]), SynthVoicePanes.format(p[\sdgbend], "s")) }),
		(type: \env, w: 1.1, title: "three layers, squashed", len: { |p| max(p[\sdgdecay] + rel.(p), max(ring.(p) * 1.2, p[\sdgnoise])) * 1.1 },
			curves: { |p| var g = drive.(p); [
				(func: { |t| (bodyEnv.(t, p) * g).tanh / g.tanh }, label: "body"),
				(func: { |t| p[\sdgmetal] * fall.(ring.(p)).(t) }, label: "clang"),
				(func: { |t| if(t < p[\sdgnoise]) { p[\sdgsnap] * 0.8 } { 0 } }, label: "noise", colour: \dim)] },
			readout: { |p| "holds % · noise gate %".format(SynthVoicePanes.format(p[\sdgdecay], "s"), SynthVoicePanes.format(p[\sdgnoise], "s")) }),
		(type: \wave, w: 0.8, title: "body", func: { |ph, p| var s = sin(ph * 2pi), f = p[\sdgwavefold], g = drive.(p);
			var b = s + ((s * (1 + (f * 5))).fold2(1) * f * 0.6); (b * g).tanh / g.tanh },
			ref: { |ph| sin(ph * 2pi) }, refLabel: "a sine", label: "driven, folded",
			readout: { |p| "drive % · fold %".format(pct.(p[\sdgdrive]), pct.(p[\sdgwavefold])) })
	],
	macros: [
		(name: "brightness", text: "tone and tick", targets: [[\sdgtone, 0.4], [\sdgclick, 0.4]]),
		(name: "timbre", text: "drive and fold", targets: [[\sdgdrive, 0.35], [\sdgwavefold, 0.4]]),
		(name: "time", text: "hold, the noise gate follows", targets: [[\sdgdecay, 0.4], [\sdgnoise, 0.4]]),
		(name: "movement", text: "how far and slow it dives", targets: [[\sdgbend, 0.5], [\sdgpunch, 0.3]])
	],
	cards: [
		(title: "dive", knobs: [
			(key: \sdgpunch, label: "from", spec: ControlSpec(0, 48, \lin, 0, 30, "st"), sub: "above tune"),
			(key: \sdgbend, label: "dive", spec: ControlSpec(0.005, 1.5, \exp, 0, 0.15, "s"), sub: "long: a swoop")]),
		(title: "character", knobs: [
			(key: \sdgdrive, label: "drive", spec: ControlSpec(0, 1), box: \pct, sub: "sine ↔ square"),
			(key: \sdgmetal, label: "clang", spec: ControlSpec(0, 1), box: \pct, sub: "struck metal")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "dark ↔ bright")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgfreq, label: "tune", size: \big, spec: ControlSpec(20, 200, \exp, 0, 45, "Hz"), sub: "where it lands", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.03, 3, \exp, 0, 0.35, "s"), sub: "holds, then cut"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	],
	fold: (title: "more", knobs: [
		(key: \sdgclick, label: "tick", spec: ControlSpec(0, 1), box: \pct, sub: "at the front"),
		(key: \sdgwavefold, label: "fold", spec: ControlSpec(0, 1), box: \pct, sub: "metallic copy"),
		(key: \sdgcolor, label: "clang pitch", spec: ControlSpec(0, 1), box: \pct, sub: "gong ↔ steel"),
		(key: \sdgsnap, label: "noise", spec: ControlSpec(0, 1), box: \pct, sub: "gated burst"),
		(key: \sdgnoise, label: "gate", spec: ControlSpec(0.005, 1, \exp, 0, 0.05, "s"), sub: "follows decay")])
)
)
