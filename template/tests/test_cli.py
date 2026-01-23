import importlib


def test_cli_default(capsys):
    cli = importlib.import_module("{{ package_name }}.cli")
    cli.main([])
    captured = capsys.readouterr()
    assert captured.out == "Hello World!\n"


def test_cli_name(capsys):
    cli = importlib.import_module("{{ package_name }}.cli")
    cli.main(["--name", "Alice"])
    captured = capsys.readouterr()
    assert captured.out == "Hello Alice!\n"
