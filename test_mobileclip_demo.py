#!/usr/bin/env python3
"""Unit test for mobileclip_demo with syrupy snapshots."""

import torch
import numpy as np
from mobileclip_demo import compute_similarity_matrix


def test_mobileclip_embeddings_and_similarity(snapshot):
    """Test MobileCLIP embeddings and similarity matrix with snapshot comparison."""
    # Set seeds for reproducible results with randomly initialized model
    torch.manual_seed(42)
    np.random.seed(42)
    
    # Test with short sentences only (no URLs to avoid network dependencies)
    test_items = ["dog", "cat", "car"]
    
    # Compute similarity matrix
    similarity_df = compute_similarity_matrix(test_items)
    
    # Round to 3 decimal places for consistent snapshots
    rounded_matrix = similarity_df.round(3)
    
    # Convert to dict for cleaner snapshot format  
    result = {
        "items": test_items,
        "similarity_matrix": rounded_matrix.to_dict(),
        "matrix_shape": rounded_matrix.shape
    }
    
    assert result == snapshot