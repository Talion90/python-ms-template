"""Tests for main module."""

import pytest


def test_main_function_exists():
    """Test that main function exists and is callable."""
    from main import main
    
    assert callable(main)


def test_main_function_runs():
    """Test that main function runs without error."""
    from main import main
    
    # Should not raise any exceptions
    main() 