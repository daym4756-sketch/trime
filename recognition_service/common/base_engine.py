from abc import ABC, abstractmethod

class BaseAIEngine(ABC):
    """
    Base class for all AI recognition engines in TRIME.
    Ensures consistency in how models are loaded and used.
    """

    def __init__(self, model_name: str):
        self.model_name = model_name
        self.is_loaded = False

    @abstractmethod
    def load_model(self):
        """Load weights and models into memory."""
        pass

    @abstractmethod
    def process(self, input_data):
        """Perform the recognition/processing task."""
        pass
