using Godot;
using System;
using System.Reflection.Metadata.Ecma335;

public partial class RayCastFloor : Node2D
{
	[Signal] public delegate void NotCollidedEventHandler();
	// Start Region of Export
	// End Region of Export
	RayCast2D rayCast2D { get; set; }
	Line2D line2D { get; set; }
	public override void _Ready()
	{
		NotCollided += () => { };
		rayCast2D = GetNode<RayCast2D>("RayCast2D");
		line2D = GetNode<Line2D>("Line2D");
		line2D.Show();
		line2D.AddPoint(rayCast2D.Position);
		line2D.AddPoint(rayCast2D.TargetPosition);
	}
	public override void _PhysicsProcess(double delta)
	{
		if (!rayCast2D.IsColliding())
		{
			GD.Print("Not Collided Triggered");
			EmitSignal(SignalName.NotCollided);
		}
	}

}
