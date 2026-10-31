// Generación solo en cloud. El APK contiene los WAV, nunca el sintetizador.
import create from '@echogarden/espeak-ng-emscripten';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const lines = JSON.parse(readFileSync(path.join(here, 'lines.json'), 'utf8'));
const engine = await create();
const speaker = new engine.eSpeakNGWorker();
if (speaker.set_voice('es-419+f3', 'es-419') !== 0) throw Error('No se pudo seleccionar la voz española');
speaker.set_rate(150);
speaker.set_pitch(53);
const dest = path.join(root, 'android/app/src/main/res/raw');
mkdirSync(dest, { recursive: true });
for (const [id, text] of Object.entries(lines)) {
  const blocks = [];
  speaker.synthesize(text, (samples) => { blocks.push(Buffer.from(samples.buffer)); return false; });
  const pcm = Buffer.concat(blocks);
  if (pcm.length < 1000) throw Error(`No se generó voz: ${id}`);
  const rate = speaker.get_samplerate();
  const header = Buffer.alloc(44);
  header.write('RIFF', 0); header.writeUInt32LE(pcm.length + 36, 4); header.write('WAVEfmt ', 8);
  header.writeUInt32LE(16, 16); header.writeUInt16LE(1, 20); header.writeUInt16LE(1, 22);
  header.writeUInt32LE(rate, 24); header.writeUInt32LE(rate * 2, 28);
  header.writeUInt16LE(2, 32); header.writeUInt16LE(16, 34); header.write('data', 36);
  header.writeUInt32LE(pcm.length, 40);
  writeFileSync(path.join(dest, `voice_${id}.wav`), Buffer.concat([header, pcm]));
}
const mappings = Object.keys(lines).map(id => `        "${id}" to R.raw.voice_${id}`).join(',\n');
writeFileSync(path.join(root, 'android/app/src/main/kotlin/com/regina/aventuras/VoiceCatalog.kt'),
  `// Generado por scripts/voice/generate.mjs. No editar a mano.\npackage com.regina.aventuras\n\nobject VoiceCatalog {\n    val clips = mapOf(\n${mappings}\n    )\n}\n`);
console.log(`${Object.keys(lines).length} clips españoles generados.`);
