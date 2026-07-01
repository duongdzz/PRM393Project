namespace TimeWise.Api.Services.Interfaces;

public interface ITokenService
{
    string GenerateToken(Guid userId, string email);
}
