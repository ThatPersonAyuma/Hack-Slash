using Godot;
using System;
using System.Threading;
using System.Threading.Tasks;

public partial class DummyKnight : CharacterBody2D
{
	// Start Region of Export
	[Export] public int Speed = 200;
	[Export] public int DashSpeed = 400;
	[Export] public float JumpVelocity = -400;
	[Export] public float Gravity = 1000;
	// [Export] public float ShakeTime = 1f;
	[Export] public float ShakeAmount = 500f;
	[Export] public double DashEnergy = 100f;
	// End Region of Export

	// Start Regiob of Attribute
	bool canChangeAnimate = false;
	string AnimatedSpriteName = "idle";
	Vector2[] FlipsH = [new Vector2(1, 1), new Vector2(-1, 1)];  // Original, FlipH
	Area2D AttackArea { get; set; }
	private AnimatedSprite2D sprite;
	bool IsAttacking = false;
	bool IsDoubleAttacking = false;
	FastNoiseLite Noise { get; set; }
	Camera2D Cam { get; set; }
	ProgressBar DashEnergyBar { get; set; }
	Vector2 CamBasePosition { get; set; }
	int toggle = 1 ;
	bool IsDash = false;
	// End Region of Attribute

	public override void _Ready()
	{
		sprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
		AttackArea = GetNode<Area2D>("Area2D");
		Cam = GetNode<Camera2D>("Camera2D");
		DashEnergyBar = Cam.GetNode<ProgressBar>("CanvasLayer/ProgressBar");
		Noise = new();
	}

	public override void _PhysicsProcess(double delta)
	{
		if (Input.IsActionJustPressed("dash") && DashEnergy >= 25)
		{
			DashEnergy -= 25;
			DashInput();
		}
		if (!IsDash)
		{
			AttackInput();
			if (!IsAttacking) CharacterMove(delta: delta);
		}
		else
		{
			MoveAndSlide();
		}
		sprite.Play(AnimatedSpriteName);
		if (DashEnergy < 100)
		{
			DashEnergy += 10 * delta;
			DashEnergyBar.Value = DashEnergy;
		}
		GD.Print(DashEnergy);
		// ProcessShake();
	}
	async Task DashInput()
	{
		float direction = Input.GetActionStrength("ui_right") - Input.GetActionStrength("ui_left");
		IsDash = true;
		Vector2 velocity = Velocity;
		AnimatedSpriteName = "dash";
		sprite.FlipH = direction != 0 ? direction < 0 : sprite.FlipH;
		velocity.X = sprite.FlipH ? -1 * DashSpeed : DashSpeed;
		Velocity = velocity;
		GD.Print("Dash Start");
		GD.Print(Velocity);
		await ToSignal(GetTree().CreateTimer(0.2), SceneTreeTimer.SignalName.Timeout);
		GD.Print("Dash Ends");
		GD.Print(Velocity);
		velocity.X = 0;
		Velocity = velocity;
		IsDash = false;
	}
	// private void ProcessShake()
	// {
	// 	CamBasePosition = Cam.Position;
	// 	Cam.GlobalPosition = CamBasePosition + new Vector2(GetNoise(0), GetNoise(1));
	// }
	private float GetNoise(int seed)
	{
		Noise.Seed = seed;
		return Noise.GetNoise1D(
			GD.Randf()
		) * ShakeAmount;
	}
	private async Task FreezeScene(double timeScale, double duration)
	{
		Engine.TimeScale = timeScale;
		await ToSignal(GetTree().CreateTimer(duration * timeScale), SceneTreeTimer.SignalName.Timeout);
		Engine.TimeScale = 1.0;
	}
	private void CharacterMove(double delta)
	{
		Vector2 velocity = Velocity;
		bool IsOnFloorVal = IsOnFloor();
		float direction = Input.GetActionStrength("ui_right") - Input.GetActionStrength("ui_left");
		// Gravity
		if (!IsOnFloorVal)
		{
			velocity.Y += Gravity * (float)delta;
			if (velocity.Y > 0)
			{
				AnimatedSpriteName = "fall";
				canChangeAnimate = false;
			}
		}
		else// default "ui_accept" = Space
		{
			if (Input.IsActionPressed("ui_accept"))
			{
				canChangeAnimate = false;
				velocity.Y = JumpVelocity;
				AnimatedSpriteName = "jump";
			}
			else
			{
				canChangeAnimate = true;
			}
		}
		// Movement x axis
		if (direction != 0)
		{
			if (direction < 0)
			{
				AttackArea.Scale = FlipsH[1];
			}
			else
			{
				AttackArea.Scale = FlipsH[0];
			}
			sprite.FlipH = direction < 0;
			// sprite.Transform.X = ;
		}
		velocity.X = direction * Speed;
		// Flip sprite
		if (canChangeAnimate)
		{
			if (direction != 0)
			{
				AnimatedSpriteName = "run";
			}
			else
			{
				AnimatedSpriteName = "idle";
			}
		}

		Velocity = velocity;
		MoveAndSlide();
	}
	void AttackInput()
	{
		if (Input.IsActionJustPressed("attack"))
		{
			GD.Print("Pressed");
			if (!IsAttacking)
			{
				Attack();
				Vector2 velocity = Velocity;
				velocity.X = 0;
			}
			else
			{
				IsDoubleAttacking = true;
			}
		}
	}
	async Task Attack()
	{
		AnimatedSpriteName = "attackComboNoMove";
		IsAttacking = true;
		AttackArea.Monitoring = true;
		
		await ToSignal(GetTree().CreateTimer(0.2), SceneTreeTimer.SignalName.Timeout);
		// DateTime time1 = DateTime.Now;
		CheckAttackArea();
		// DateTime time2 = DateTime.Now;
		// GD.Print($"Time Neede: {time2-time1}");

		await ToSignal(GetTree().CreateTimer(0.2), SceneTreeTimer.SignalName.Timeout);

		if (IsDoubleAttacking)
		{
			await ToSignal(GetTree().CreateTimer(0.2), SceneTreeTimer.SignalName.Timeout);
			CheckAttackArea();

			await ToSignal(GetTree().CreateTimer(0.2), SceneTreeTimer.SignalName.Timeout);
			AttackArea.Monitoring = false;
			IsAttacking = false;
			IsDoubleAttacking = false;
		}
		else
		{
			AttackArea.Monitoring = false;
			IsAttacking = false;
		}
	}
	private async Task CheckAttackArea()
	{
		DateTime time1 = DateTime.Now;
		Godot.Collections.Array<Area2D>  Overlapp = AttackArea.GetOverlappingAreas();
		if (Overlapp.Count > 0)
		{
			Task freezeTAsk = FreezeScene(timeScale: 0.005, duration: 0.5);
			while (!freezeTAsk.IsCompleted)
			{
				Cam.Offset = new Vector2(Cam.Position.X + 3 * toggle, Cam.Position.Y + 3 * toggle);
				toggle *= -1;
				await Task.Delay(80);
			}
			Cam.Offset = new Vector2(0, 0);
			GD.Print("Ada yang overlap");
			DateTime time2 = DateTime.Now;
			GD.Print($"Time Neede: {time2-time1}");
		}
	}
}
