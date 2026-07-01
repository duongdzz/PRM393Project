using TimeWise.Api.DTOs.Auth;

namespace TimeWise.Api.Services.Interfaces;

public interface IAuthService
{
    Task<AuthResponse> SignInWithGoogleAsync(GoogleAuthRequest request);

    /// <summary>Chỉ dùng Development — lấy JWT test Swagger.</summary>
    Task<AuthResponse> SignInDevAsync();
}
