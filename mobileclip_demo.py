#!/usr/bin/env python3
"""
MobileCLIP-S1 Demo: Create embeddings for text and images, compute similarity matrix, and visualize.
"""

import torch
import pandas as pd
import numpy as np
import plotly.express as px
from functools import lru_cache
from PIL import Image
from scipy.spatial.distance import pdist, squareform
from tqdm import tqdm
import requests
import open_clip
from typing import List, Union
import io


def setup_model():
    """Initialize MobileCLIP model and transforms from open_clip."""
    model, _, preprocess = open_clip.create_model_and_transforms('MobileCLIP-S1')
    tokenizer = open_clip.get_tokenizer('MobileCLIP-S1')
    return model, preprocess, tokenizer


@lru_cache(maxsize=128)
def fetch_image(url: str) -> Image.Image:
    """Fetch and cache image from URL."""
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    return Image.open(io.BytesIO(response.content)).convert('RGB')


def create_embedding(item: str, model, preprocess, tokenizer, device='cpu') -> np.ndarray:
    """Create embedding for text or image URL."""
    with torch.no_grad():
        if item.startswith('http'):
            # Image embedding
            image = fetch_image(item)
            image_tensor = preprocess(image).unsqueeze(0).to(device)
            embedding = model.encode_image(image_tensor)
        else:
            # Text embedding
            text_tokens = tokenizer([item]).to(device)
            embedding = model.encode_text(text_tokens)
        
        # Normalize embedding
        embedding = embedding / embedding.norm(dim=-1, keepdim=True)
        return embedding.cpu().numpy().flatten()


def compute_similarity_matrix(items: List[str]) -> pd.DataFrame:
    """Compute pairwise cosine similarity matrix for list of items."""
    print("Setting up MobileCLIP model...")
    model, preprocess, tokenizer = setup_model()
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    model = model.to(device)
    model.eval()
    
    print(f"Creating embeddings for {len(items)} items...")
    embeddings = []
    
    for item in tqdm(items, desc="Processing items"):
        try:
            embedding = create_embedding(item, model, preprocess, tokenizer, device)
            embeddings.append(embedding)
        except Exception as e:
            print(f"Error processing '{item}': {e}")
            # Use zero embedding as fallback
            embeddings.append(np.zeros(512))  # MobileCLIP-S1 has 512-dim embeddings
    
    embeddings = np.array(embeddings)
    
    print("Computing cosine similarity matrix...")
    # Compute cosine distances (1 - cosine similarity)
    distances = pdist(embeddings, metric='cosine')
    similarity_matrix = 1 - squareform(distances)
    
    # Create DataFrame with item names as index and columns
    df = pd.DataFrame(similarity_matrix, index=items, columns=items)
    return df


def visualize_similarity_heatmap(similarity_df: pd.DataFrame, title: str = "MobileCLIP Similarity Matrix"):
    """Create interactive heatmap visualization with rotated column labels."""
    fig = px.imshow(
        similarity_df.values,
        x=similarity_df.columns,
        y=similarity_df.index,
        color_continuous_scale='Viridis',
        title=title,
        aspect='auto'
    )
    
    # Rotate column labels 90 degrees
    fig.update_layout(
        xaxis_tickangle=-90,
        width=max(800, len(similarity_df.columns) * 50),
        height=max(600, len(similarity_df.index) * 30),
        margin=dict(b=150)  # Extra bottom margin for rotated labels
    )
    
    return fig


def demo_mobileclip(items: List[str]):
    """Main demo function."""
    print(f"MobileCLIP Demo with {len(items)} items")
    print("Items:", items[:5], "..." if len(items) > 5 else "")
    
    # Compute similarity matrix
    similarity_df = compute_similarity_matrix(items)
    
    print("\nSimilarity Matrix:")
    print(similarity_df.round(3))
    
    # Create visualization
    print("\nCreating visualization...")
    fig = visualize_similarity_heatmap(similarity_df)
    fig.show()
    
    return similarity_df


if __name__ == "__main__":
    # Example usage with mix of text and image URLs
    sample_items = [
        "a dog",
        "a cat",
        "a car", 
        "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Collage_of_Nine_Dogs.jpg/640px-Collage_of_Nine_Dogs.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Cat_poster_1.jpg/640px-Cat_poster_1.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Tesla_Model_S_Indoors.jpg/640px-Tesla_Model_S_Indoors.jpg",
        "animal",
        "vehicle",
        "pet"
    ]
    
    print("Running MobileCLIP demo...")
    similarity_matrix = demo_mobileclip(sample_items)