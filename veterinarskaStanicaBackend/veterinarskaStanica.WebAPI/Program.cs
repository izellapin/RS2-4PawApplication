using eVeterinarskaStanicaServices;
using eVeterinarskaStanicaServices.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

namespace veterinarskaStanica.WebAPI
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
            builder.Services.AddDatabaseServices(connectionString);

            builder.Services.AddTransient<iServiceService, DummyServiceService>();
            builder.Services.AddScoped<IAuthService, AuthService>();

            // ===== JWT Authentication (no fallbacks, consistent UTF8) =====
            var jwtSecret = builder.Configuration["JWT:Secret"];
            if (string.IsNullOrWhiteSpace(jwtSecret))
            {
                throw new InvalidOperationException("JWT:Secret is not configured.");
            }

            var keyBytes = Encoding.UTF8.GetBytes(jwtSecret);
            var signingKey = new SymmetricSecurityKey(keyBytes);

            builder.Services
                .AddAuthentication(options =>
                {
                    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                })
                .AddJwtBearer(options =>
                {
                    options.RequireHttpsMetadata = false; // set true in production behind HTTPS
                    options.SaveToken = true;
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = signingKey,

                        // Keep issuer/audience disabled for now since you don't set them when issuing the token.
                        // If you add them later, set these to true and configure ValidIssuer/ValidAudience.
                        ValidateIssuer = false,
                        ValidateAudience = false,

                        // Be strict on time drift
                        ClockSkew = TimeSpan.Zero,

                        // Ensure only HS256 is accepted (matches your token issuing code)
                        ValidAlgorithms = new[] { SecurityAlgorithms.HmacSha256 },

                        // Explicit for clarity
                        ValidateLifetime = true
                    };
                });

            builder.Services.AddControllers();

            // ===== CORS =====
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll", policy =>
                {
                    policy.AllowAnyOrigin()
                          .AllowAnyMethod()
                          .AllowAnyHeader();
                });
            });

            // ===== Swagger/OpenAPI =====
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "Veterinary Clinic API",
                    Version = "v1",
                    Description = "API for Veterinary Clinic Management System with role-based authentication"
                });

                // Use proper HTTP Bearer scheme so the UI can prepend "Bearer " automatically if desired
                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Description = "JWT Authorization using the Bearer scheme. Enter your token below.",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer",
                    BearerFormat = "JWT"
                });

                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            }
                        },
                        Array.Empty<string>()
                    }
                });
            });

            // ===== Health checks =====
            builder.Services.AddHealthChecks();

            // ===== RabbitMQ Background Service (optional) =====
            var rabbitMQEnabled = builder.Configuration.GetValue<bool>("RabbitMQ:Enabled", true);
            if (rabbitMQEnabled)
            {
                builder.Services.AddHostedService<NotificationSubscriberService>();
            }

            var app = builder.Build();

            // Apply pending migrations and seed data
            using (var scope = app.Services.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                context.Database.Migrate();

                try
                {
                    var seeder = scope.ServiceProvider.GetRequiredService<IDataSeederService>();
                    await seeder.SeedInitialDataAsync();
                }
                catch (Exception ex)
                {
                    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
                    logger.LogError(ex, "Error occurred during data seeding, but application will continue");
                }
            }

            // ===== HTTP pipeline =====
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseCors("AllowAll");

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapHealthChecks("/health");
            app.MapControllers();

            app.Run();
        }
    }
}
