import numpy as np
import gradio as gr
from bark import SAMPLE_RATE, generate_audio, preload_models
from bark.generation import SUPPORTED_LANGS

DEBUG_MODE = False

# if not DEBUG_MODE:
#     _ = preload_models()

AVAILABLE_PROMPTS = ["Unconditional", "Announcer"]
PROMPT_LOOKUP = {}
for _, lang in SUPPORTED_LANGS:
    for n in range(10):
        label = f"Speaker {n} ({lang})"
        AVAILABLE_PROMPTS.append(label)
        PROMPT_LOOKUP[label] = f"{lang}_speaker_{n}"
PROMPT_LOOKUP["Unconditional"] = None
PROMPT_LOOKUP["Announcer"] = "announcer"

default_text = "Hello, my name is Suno. And, uh — and I like pizza. [laughs]\nBut I also have other interests such as playing tic tac toe."

title = "# 🐶 Bark</div>"

description = """
Bark is a universal text-to-audio model created by [Suno](www.suno.ai), with code publicly available [here](https://github.com/suno-ai/bark). \
Bark can generate highly realistic, multilingual speech as well as other audio - including music, background noise and simple sound effects. \
This demo should be used for research purposes only. Commercial use is strictly prohibited. \
The model output is not censored and the authors do not endorse the opinions in the generated content. \
Use at your own risk.
"""

article = """
## 🌎 Foreign Language
Bark supports various languages out-of-the-box and automatically determines language from input text. \
When prompted with code-switched text, Bark will even attempt to employ the native accent for the respective languages in the same voice.
Try the prompt:
```
Buenos días Miguel. Tu colega piensa que tu alemán es extremadamente malo. But I suppose your english isn't terrible.
```
## 🤭 Non-Speech Sounds
Below is a list of some known non-speech sounds, but we are finding more every day. \
Please let us know if you find patterns that work particularly well on Discord!
* [laughter]
* [laughs]
* [sighs]
* [music]
* [gasps]
* [clears throat]
* — or ... for hesitations
* ♪ for song lyrics
* capitalization for emphasis of a word
* MAN/WOMAN: for bias towards speaker
Try the prompt:
```
" [clears throat] Hello, my name is Suno. And, uh — and I like pizza. [laughs] But I also have other interests such as... ♪ singing ♪."
```
## 🎶 Music
Bark can generate all types of audio, and, in principle, doesn't see a difference between speech and music. \
Sometimes Bark chooses to generate text as music, but you can help it out by adding music notes around your lyrics.
Try the prompt:
```
♪ In the jungle, the mighty jungle, the lion barks tonight ♪
```
## 🧬 Voice Cloning
Bark has the capability to fully clone voices - including tone, pitch, emotion and prosody. \
The model also attempts to preserve music, ambient noise, etc. from input audio. \
However, to mitigate misuse of this technology, we limit the audio history prompts to a limited set of Suno-provided, fully synthetic options to choose from.
## 👥 Speaker Prompts
You can provide certain speaker prompts such as NARRATOR, MAN, WOMAN, etc. \
Please note that these are not always respected, especially if a conflicting audio history prompt is given.
Try the prompt:
```
WOMAN: I would like an oatmilk latte please.
MAN: Wow, that's expensive!
```
## Details
Bark model by [Suno](https://suno.ai/), including official [code](https://github.com/suno-ai/bark) and model weights. \
Gradio demo supported by 🤗 Hugging Face. Bark is licensed under a non-commercial license: CC-BY 4.0 NC, see details on [GitHub](https://github.com/suno-ai/bark).
"""

examples = [
    ["Please surprise me and speak in whatever voice you enjoy. Vielen Dank und Gesundheit!",
        "Unconditional"],  # , 0.7, 0.7],
    ["Hello, my name is Suno. And, uh — and I like pizza. [laughs] But I also have other interests such as playing tic tac toe.",
        "Speaker 1 (en)"],  # , 0.7, 0.7],
    ["Buenos días Miguel. Tu colega piensa que tu alemán es extremadamente malo. But I suppose your english isn't terrible.",
        "Speaker 0 (es)"],  # , 0.7, 0.7],
]


def gen_tts(text, history_prompt):  # , temp_semantic, temp_waveform):
    history_prompt = PROMPT_LOOKUP[history_prompt]
    if DEBUG_MODE:
        audio_arr = np.zeros(SAMPLE_RATE)
    else:
        # , text_temp=temp_semantic, waveform_temp=temp_waveform)
        audio_arr = generate_audio(text, history_prompt=history_prompt)
    audio_arr = (audio_arr * 32767).astype(np.int16)
    return (SAMPLE_RATE, audio_arr)


css = """
        #share-btn-container {
            display: flex;
            padding-left: 0.5rem !important;
            padding-right: 0.5rem !important;
            background-color: #000000;
            justify-content: center;
            align-items: center;
            border-radius: 9999px !important; 
            width: 13rem;
            margin-top: 10px;
            margin-left: auto;
            flex: unset !important;
        }
        #share-btn {
            all: initial;
            color: #ffffff;
            font-weight: 600;
            cursor: pointer;
            font-family: 'IBM Plex Sans', sans-serif;
            margin-left: 0.5rem !important;
            padding-top: 0.25rem !important;
            padding-bottom: 0.25rem !important;
            right:0;
        }
        #share-btn * {
            all: unset !important;
        }
        #share-btn-container div:nth-child(-n+2){
            width: auto !important;
            min-height: 0px !important;
        }
        #share-btn-container .wrap {
            display: none !important;
        }
"""
with gr.Blocks(css=css) as block:
    gr.Markdown(title)
    gr.Markdown(description)
    with gr.Row():
        with gr.Column():
            input_text = gr.Textbox(
                label="Input Text", lines=2, value=default_text, elem_id="input_text")
            options = gr.Dropdown(
                AVAILABLE_PROMPTS, value="Speaker 1 (en)", label="Acoustic Prompt", elem_id="speaker_option")
            run_button = gr.Button("Generate Audio", variant="primary")
        with gr.Column():
            audio_out = gr.Audio(label="Generated Audio",
                                 type="numpy", elem_id="audio_out")

    inputs = [input_text, options]
    outputs = [audio_out]
    run_button.click(fn=gen_tts, inputs=inputs, outputs=outputs),
    gr.Examples(examples=examples, fn=gen_tts, inputs=inputs,
                outputs=outputs, cache_examples=False)
    gr.Markdown(article)

block.queue()
block.launch(server_name="0.0.0.0", server_port=7860)