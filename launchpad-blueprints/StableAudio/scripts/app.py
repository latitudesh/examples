import torch
import torchaudio
from einops import rearrange
import gradio as gr
import uuid
import json
import os
from datetime import datetime

# Importing the model-related functions
# from stable_audio_tools import get_pretrained_model
from stable_audio_tools.interface.gradio import load_model

from stable_audio_tools.inference.generation import generate_diffusion_cond

# Load the model outside of the GPU-decorated function


def load_model_sa():
    with open("./model_config.json") as f:
        model_config = json.load(f)
    model, model_config = load_model(
        model_ckpt_path="./model.safetensors", model_config=model_config)
    print("Loading model...Done")
    return model, model_config

# Function to set up, generate, and process the audio


def generate_audio(prompt, sampler_type_dropdown, seconds_total=30, steps=100, cfg_scale=7, sigma_min_slider=0.3, sigma_max_slider=500):
    print(f"Prompt received: {prompt}")
    print(
        f"Settings: Duration={seconds_total}s, Steps={steps}, CFG Scale={cfg_scale}")

    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Using device: {device}")

    # Fetch the Hugging Face token from the environment variable
    # hf_token = os.getenv('HF_TOKEN')
    # print(f"Hugging Face token: {hf_token}")

    # Use pre-loaded model and configuration
    model, model_config = load_model_sa()
    sample_rate = model_config["sample_rate"]
    sample_size = model_config["sample_size"]

    print(f"Sample rate: {sample_rate}, Sample size: {sample_size}")

    model = model.to(device)
    print("Model moved to device.")

    # Set up text and timing conditioning
    conditioning = [{
        "prompt": prompt,
        "seconds_start": 0,
        "seconds_total": seconds_total
    }]
    print(f"Conditioning: {conditioning}")

    # Generate stereo audio
    print("Generating audio...")
    output = generate_diffusion_cond(
        model,
        steps=steps,
        cfg_scale=cfg_scale,
        conditioning=conditioning,
        sample_size=sample_size,
        sigma_min=sigma_min_slider,
        sigma_max=sigma_max_slider,
        sampler_type=sampler_type_dropdown,  # "dpmpp-3m-sde",
        device=device
    )
    print("Audio generated.")

    # Rearrange audio batch to a single sequence
    output = rearrange(output, "b d n -> d (b n)")
    print("Audio rearranged.")

    # Peak normalize, clip, convert to int16
    output = output.to(torch.float32).div(
        torch.max(torch.abs(output))).clamp(-1, 1).mul(32767).to(torch.int16).cpu()

    max_length = sample_rate * seconds_total
    if output.shape[1] > max_length:
        output = output[:, :max_length]
        print(f"Audio trimmed to {seconds_total} seconds.")

    current_date = datetime.now().strftime("%Y%m%d")

    wav_directory = os.path.join(os.getcwd(), 'output')
    os.makedirs(wav_directory, exist_ok=True)
    wav_path = os.path.join(wav_directory, f"{uuid.uuid4()}.wav")

    torchaudio.save(wav_path, output, model_config["sample_rate"])
    return [gr.make_waveform(wav_path), wav_path]


# Setting up the Gradio Interface
interface = gr.Interface(
    fn=generate_audio,

    inputs=[
        gr.Textbox(label="Prompt", placeholder="Enter your text prompt here"),
        gr.Dropdown(["dpmpp-2m-sde", "dpmpp-3m-sde", "k-heun", "k-lms", "k-dpmpp-2s-ancestral",
                    "k-dpm-2", "k-dpm-fast"], label="Sampler type", value="dpmpp-3m-sde"),
        gr.Slider(0, 47, value=30, step=1, label="Duration in Seconds"),
        gr.Slider(10, 150, value=100, step=10,
                  label="Number of Diffusion Steps"),
        gr.Slider(1, 15, value=7, step=0.1, label="CFG Scale"),
        gr.Slider(minimum=0.0, maximum=5.0, step=0.01,
                  value=0.3, label="Sigma min"),
        gr.Slider(minimum=0.0, maximum=1000.0, step=0.1,
                  value=500, label="Sigma max"),

    ],
    outputs=[gr.Video(label="Generated Audio Wave"), gr.Audio(type="numpy", label="Generated Audio",
                                                              interactive=False),],
    title="Stable Audio Generator",
    description="Generate variable-length stereo audio at 44.1kHz from text prompts using Stable Audio Open 1.0.",
    examples=[
        [
            "Create a serene soundscape of a quiet beach at sunset.",  # Text prompt
            "dpmpp-2m-sde",  # Sampler type
            45,  # Duration in Seconds
            100,  # Number of Diffusion Steps
            10,  # CFG Scale
            0.5,  # Sigma min
            800  # Sigma max
        ],
        [
            "clapping",  # Text prompt
            "dpmpp-3m-sde",  # Sampler type
            30,  # Duration in Seconds
            100,  # Number of Diffusion Steps
            7,  # CFG Scale
            0.5,  # Sigma min
            500  # Sigma max
        ],
        [
            "Simulate a forest ambiance with birds chirping and wind rustling through the leaves.",  # Text prompt
            "k-dpm-fast",  # Sampler type
            60,  # Duration in Seconds
            140,  # Number of Diffusion Steps
            7.5,  # CFG Scale
            0.3,  # Sigma min
            700  # Sigma max
        ],
        [
            "Recreate a gentle rainfall with distant thunder.",  # Text prompt
            "dpmpp-3m-sde",  # Sampler type
            35,  # Duration in Seconds
            110,  # Number of Diffusion Steps
            8,  # CFG Scale
            0.1,  # Sigma min
            500  # Sigma max
        ],
        [
            "Imagine a jazz cafe environment with soft music and ambient chatter.",  # Text prompt
            "k-lms",  # Sampler type
            25,  # Duration in Seconds
            90,  # Number of Diffusion Steps
            6,  # CFG Scale
            0.4,  # Sigma min
            650  # Sigma max
        ],
        ["Rock beat played in a treated studio, session drumming on an acoustic kit.",
         "dpmpp-2m-sde",  # Sampler type
         30,  # Duration in Seconds
         100,  # Number of Diffusion Steps
         7,  # CFG Scale
         0.3,  # Sigma min
         500  # Sigma max
         ]
    ]
)

# Pre-load the model to avoid multiprocessing issues
model, model_config = load_model_sa()

# Launch the Interface
interface.queue().launch(server_name="0.0.0.0")