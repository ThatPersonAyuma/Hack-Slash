using Godot;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.Net.Http;

public partial class Nanda : CharacterBody2D
{
	// Start Region of Export
	[Export] public int Speed = 100;
	[Export] public float JumpVelocity = -400;
	[Export] public float Gravity = 1000;
	// [Export] public float ShakeTime = 1f;
	[Export] public float ShakeAmount = 500f;
	[Export] public int CamLimitLeft = -10000000;
	[Export] public int CamLimitTop = -10000000;
	[Export] public int CamLimitRight = 10000000;
	[Export] public int CamLimitBottom = 10000000;
	[Export] public float ZoomValue = 1F;
	// End Region of Export

	// Start Regiob of Attribute
	bool canChangeAnimate = false;
	string AnimatedSpriteName = "idle";
	Vector2[] FlipsH = [new Vector2(1, 1), new Vector2(-1, 1)];  // Original, FlipH
	private AnimatedSprite2D sprite;
	bool IsAttacking = false;
	bool IsDoubleAttacking = false;
	Camera2D Cam { get; set; }
	Vector2 CamBasePosition { get; set; }
	Node GlobalVar { get; set; }
	// End Region of Attribute

	public override void _Ready()
	{
		sprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
		Cam = GetNode<Camera2D>("Camera2D");
		Cam.LimitLeft = CamLimitLeft; Cam.LimitTop = CamLimitTop;
		Cam.LimitRight = CamLimitRight; Cam.LimitBottom = CamLimitBottom;
		Cam.Zoom = new Vector2(ZoomValue, ZoomValue);
		GlobalVar = GetNode<Node>("/root/Global");
		GetIPAddressAsync();
		var host = Dns.GetHostEntry(Dns.GetHostName());
		GD.Print(host.HostName);
		foreach (var ip in host.AddressList)
		{
			// IPv4 dan bukan loopback
			GD.Print(ip.ToString());
		}
		// throw new Exception("Tidak ditemukan alamat IP lokal (IPv4).");
	}
	private async Task GetIPAddressAsync()
	{
		using (var req_client = new System.Net.Http.HttpClient())
		{
			// create http reuqest message
			using (var request = new HttpRequestMessage(
				HttpMethod.Get,
				"https://api.ipify.org?format=json"))
			{
				// Adding header to the http request message
				request.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
				request.Headers.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8");

				var response = await req_client.SendAsync(request); // Send the h
				if (response.IsSuccessStatusCode)
				{
					string html = await response.Content.ReadAsStringAsync();
					GD.Print(html.Split("\"")[3]);

					using (var request2 = new HttpRequestMessage(
						HttpMethod.Get,
						$"https://ipinfo.io/{html.Split("\"")[3]}/json"))
					{
						GD.Print("Processing second req");
						request2.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
						request2.Headers.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8");

						var response2 = await req_client.SendAsync(request2); // Send the h
						GD.Print("request sended");
						if (response2.IsSuccessStatusCode)
						{
							string html2 = await response2.Content.ReadAsStringAsync();
							GD.Print(html2);
						}
						else
						{
							GD.Print("Failed");
						}
					}
				}
			}
			
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		if (!IsOnFloor())
		{
			Vector2 velocity = Velocity;
			velocity.Y += Gravity * (float)delta;
			if (velocity.Y > 0)
			{
				canChangeAnimate = false;
			}
			Velocity = velocity;
			MoveAndSlide();
		}
		if ((bool)GlobalVar.Get("CanCharMove"))
		{
			CharacterMove(delta: delta);
		}
		else
		{
			AnimatedSpriteName = "idle";
		}
		sprite.Play(AnimatedSpriteName);
		// ProcessShake();
	}
	private void CharacterMove(double delta)
	{
		Vector2 velocity = Velocity;
		bool IsOnFloorVal = IsOnFloor();
		float direction = Input.GetActionStrength("ui_right") - Input.GetActionStrength("ui_left");
		// Gravity

		if (IsOnFloor())// default "ui_accept" = Space
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
			// sprite.Transform.X = ;
		velocity.X = direction * Speed;
		// Flip sprite
		if (canChangeAnimate)
		{
			if (direction != 0)
			{
				AnimatedSpriteName = "walk";
				sprite.FlipH = direction < 0;
			}
			else
			{
				AnimatedSpriteName = "idle";
			}
		}
		Velocity = velocity;
		MoveAndSlide();
	}
}
