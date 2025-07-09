using Godot;
using System;

public partial class FallBorder : Area2D
{
	public override void _Ready()
	{
		BodyEntered += OnBodyEntered;
	}
	private void OnBodyEntered(Node2D body)
	{
		if (body.IsInGroup("Player"))
		{
			GD.Print("Player jatuh!");
			// Contoh: reset posisi
			body.Position = new Vector2(100, 50);
		}
	}
}
