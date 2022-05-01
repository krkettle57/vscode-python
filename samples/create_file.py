from pathlib import Path


def write_message(filepath: Path, message: str) -> None:
    filepath.write_text(message)


if __name__ == "__main__":
    filepath = Path("./message.txt")
    write_message(filepath, "Hello World")
