// panels/sdgrim.scd - what the rimshot's window shows (SynthVoiceWindow): a struck filter
// ping, a lower body under it, a tick of noise, and the clipping that makes the crack.
(
var pct = { |v| (v * 100).round.asInteger.asString ++ " %" };
var hz = { |f| SynthVoicePanes.format(f, "Hz") ++ " · " ++ SynthVoicePanes.noteName(f) };
var tuneOf = { |p| 2 ** ((p[\note] ? 0) / 12) };
var fPing = { |p| p[\sdgcut] * tuneOf.(p) };
var bodyX = { |p| p[\sdgcolor].clip(0, 1).linexp(0, 1, 0.1, 0.8) };
var mixOf = { |p| var t = p[\sdgtone]; [t.sqrt, (1 - t).sqrt] / (t.sqrt + (1 - t).sqrt) };
// Env([0, 1, 0], [0.0002, d], [0, -6]): the struck fall
var fall = { |d, c = -6| { |t| var u = (t / d.max(0.0001)).clip(0, 1); 1 - ((1 - exp(c * u)) / (1 - exp(c))) } };
var tickLen = { |p| 0.004 + (p[\sdgdecay] * 0.4).min(0.012) };
(
	colour: \gold, drum: true,
	hint: "tune - the ping, 200 Hz to 8 kHz with its note: 1710 Hz the 808 rim, 2420 its claves; the body sits under it",
	panes: [
		(type: \partials, w: 1.1, title: "ping, body and tick", lo: 100, hi: 16000,
			list: { |p| var m = mixOf.(p), tonal = (1 - p[\sdgsnap]).sqrt; [
				(hz: fPing.(p), level: (m[0] * tonal).max(0.04), label: "ping"),
				(hz: fPing.(p) * bodyX.(p), level: (m[1] * tonal).max(0.04), colour: \wave, label: "body")] },
			band: { |p| [p[\sdgtone].linexp(0, 1, 1000, 6000), 16000, p[\sdgsnap].sqrt * 0.8, "tick"] },
			readout: { |p| "ping % · body x%".format(hz.(fPing.(p)), bodyX.(p).round(0.01)) }),
		(type: \env, w: 1.0, title: "a struck filter", len: { |p| (p[\sdgdecay] * 1.6).max(tickLen.(p) * 1.2) },
			curves: { |p| var m = mixOf.(p) * (1 - p[\sdgsnap]).sqrt, k = p[\sdgsnap].sqrt * 1.2, top = (m ++ [k]).maxItem.max(0.01); [
				(func: { |t| m[0] / top * fall.(p[\sdgdecay]).(t) }, label: "ping", colour: \id),
				(func: { |t| m[1] / top * fall.(p[\sdgdecay] * 1.5).(t) }, label: "body, 1.5 x longer", colour: \wave),
				(func: { |t| k / top * fall.(tickLen.(p), -4).(t) }, label: "tick", colour: \dim)] },
			readout: { |p| "ping % · body %".format(SynthVoicePanes.format(p[\sdgdecay], "s"), SynthVoicePanes.format(p[\sdgdecay] * 1.5, "s")) }),
		(type: \wave, w: 0.75, title: "the crack", cycles: 2,
			func: { |ph, p| var g = 1 + (p[\sdgdrive] * 8); (sin(ph * 2pi) * g).tanh / g.tanh },
			ref: { |ph| sin(ph * 2pi) }, refLabel: "clean", label: "clipped",
			readout: { |p| "drive % · x% into the clip".format(pct.(p[\sdgdrive]), (1 + (p[\sdgdrive] * 8)).round(0.1)) })
	],
	macros: [
		(name: "brightness", text: "ping over body, more tick", targets: [[\sdgtone, 0.35], [\sdgsnap, 0.3]]),
		(name: "timbre", text: "the crack and the tick", targets: [[\sdgdrive, 0.45], [\sdgsnap, 0.2]]),
		(name: "time", text: "how long it rings", targets: [[\sdgdecay, 0.45]]),
		(name: "movement", text: "where the body sits", targets: [[\sdgcolor, 0.4], [\sdgtone, 0.2]])
	],
	cards: [
		(title: "body", knobs: [(key: \sdgcolor, label: "body", spec: ControlSpec(0, 1), box: \pct, sub: "0.1 to 0.8 of ping")]),
		(title: "hit", knobs: [
			(key: \sdgsnap, label: "tick", spec: ControlSpec(0, 1), box: \pct, sub: "noise"),
			(key: \sdgdrive, label: "crack", spec: ControlSpec(0, 1), box: \pct, sub: "clipping")]),
		(title: "colour", knobs: [(key: \sdgtone, label: "tone", spec: ControlSpec(0, 1), box: \pct, sub: "body ↔ ping")]),
		(title: "voice", coloured: true, knobs: [
			(key: \sdgcut, label: "tune", size: \big, spec: ControlSpec(200, 8000, \exp, 0, 1710, "Hz"), sub: "the ping", vary: false),
			(key: \sdgdecay, label: "decay", size: \big, spec: ControlSpec(0.005, 0.5, \exp, 0, 0.015, "s"), sub: "body 1.5 x"),
			(key: \sdglevel, label: "level", spec: ControlSpec(-36, 6, \lin, 0, 0, "dB"), sub: "0 as measured", vary: false)])
	]
)
)
