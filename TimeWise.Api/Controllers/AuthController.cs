using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TimeWise.Api.DTOs.Auth;
using TimeWise.Api.Services.Interfaces;

namespace TimeWise.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IWebHostEnvironment _environment;

    public AuthController(IAuthService authService, IWebHostEnvironment environment)
    {
        _authService = authService;
        _environment = environment;
    }

    /// <summary>Đăng nhập Google — Flutter gửi idToken từ Google Sign-In.</summary>
    [HttpPost("google")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> SignInWithGoogle([FromBody] GoogleAuthRequest request)
    {
        try
        {
            var response = await _authService.SignInWithGoogleAsync(request);
            return Ok(response);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception)
        {
            return Unauthorized(new { message = "Google token không hợp lệ." });
        }
    }

    /// <summary>Development only — lấy JWT để test Swagger (không cần Google token).</summary>
    [HttpPost("dev")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> DevSignIn()
    {
        if (!_environment.IsDevelopment())
            return NotFound();

        var response = await _authService.SignInDevAsync();
        return Ok(response);
    }
}
