using Google.Apis.Auth;
using TimeWise.Api.DTOs.Auth;
using TimeWise.Api.Entities;
using TimeWise.Api.Repositories.Interfaces;
using TimeWise.Api.Services.Interfaces;

namespace TimeWise.Api.Services;

public class AuthService : IAuthService
{
    private readonly IUserRepository _users;
    private readonly ITokenService _tokens;
    private readonly string _googleClientId;

    public AuthService(
        IUserRepository users,
        ITokenService tokens,
        IConfiguration configuration)
    {
        _users = users;
        _tokens = tokens;
        _googleClientId = configuration["GoogleAuth:ClientId"]
            ?? throw new InvalidOperationException("GoogleAuth:ClientId chưa được cấu hình.");
    }

    public async Task<AuthResponse> SignInWithGoogleAsync(GoogleAuthRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.IdToken))
            throw new ArgumentException("IdToken là bắt buộc.");

        var validationSettings = new GoogleJsonWebSignature.ValidationSettings
        {
            Audience = [_googleClientId]
        };

        var payload = await GoogleJsonWebSignature.ValidateAsync(request.IdToken, validationSettings);

        var googleId = payload.Subject;
        var email = payload.Email ?? string.Empty;
        var displayName = payload.Name ?? email;
        var photoUrl = payload.Picture ?? string.Empty;
        var now = DateTime.UtcNow;

        var user = await _users.GetByGoogleIdAsync(googleId);
        if (user is null)
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                GoogleId = googleId,
                Email = email,
                DisplayName = displayName,
                PhotoUrl = photoUrl,
                CreatedAt = now,
                UpdatedAt = now
            };
            await _users.AddAsync(user);
        }
        else
        {
            user.Email = email;
            user.DisplayName = displayName;
            user.PhotoUrl = photoUrl;
            user.UpdatedAt = now;
            await _users.UpdateAsync(user);
        }

        var token = _tokens.GenerateToken(user.Id, user.Email ?? string.Empty);

        return new AuthResponse
        {
            Token = token,
            UserId = user.Id.ToString(),
            DisplayName = user.DisplayName,
            Email = user.Email ?? string.Empty,
            PhotoUrl = user.PhotoUrl ?? string.Empty
        };
    }

    public async Task<AuthResponse> SignInDevAsync()
    {
        const string devGoogleId = "dev-swagger-user";
        var now = DateTime.UtcNow;

        var user = await _users.GetByGoogleIdAsync(devGoogleId);
        if (user is null)
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                GoogleId = devGoogleId,
                Email = "dev@timewise.local",
                DisplayName = "Dev Swagger",
                CreatedAt = now,
                UpdatedAt = now
            };
            await _users.AddAsync(user);
        }

        var token = _tokens.GenerateToken(user.Id, user.Email ?? string.Empty);
        return new AuthResponse
        {
            Token = token,
            UserId = user.Id.ToString(),
            DisplayName = user.DisplayName,
            Email = user.Email ?? string.Empty,
            PhotoUrl = user.PhotoUrl ?? string.Empty
        };
    }
}
