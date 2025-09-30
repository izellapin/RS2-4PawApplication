using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using eVeterinarskaStanicaModel;
using eVeterinarskaStanicaServices.Database;

namespace eVeterinarskaStanicaServices
{
    public class DataSeederService : IDataSeederService
    {
        private readonly ApplicationDbContext _context;
        private readonly IHashingService _hashingService;
        private readonly ILogger<DataSeederService> _logger;

        public DataSeederService(ApplicationDbContext context, IHashingService hashingService, ILogger<DataSeederService> logger)
        {
            _context = context;
            _hashingService = hashingService;
            _logger = logger;
        }

        public async Task SeedInitialDataAsync()
        {
            try
            {
                _logger.LogInformation("Starting initial data seeding...");

                // Ensure database is created
                await _context.Database.EnsureCreatedAsync();

                // Seed in order of dependencies
                await SeedAdminUserAsync();
                await SeedCategoriesAsync();
                await SeedServicesAsync();

                _logger.LogInformation("Initial data seeding completed successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during data seeding");
                throw;
            }
        }

        public async Task SeedAdminUserAsync()
        {
            try
            {
                // Check if admin user already exists
                var existingAdmin = await _context.Users
                    .FirstOrDefaultAsync(u => u.Role == UserRole.Admin);

                if (existingAdmin != null)
                {
                    _logger.LogInformation("Admin user already exists, skipping admin seeding");
                    return;
                }

                // Create default admin user
                var adminPassword = "Admin123!";
                var adminHash = _hashingService.HashPassword(adminPassword, out byte[] adminSalt);

                var adminUser = new User
                {
                    FirstName = "admin",
                    LastName = "admin",
                    Email = "izellapin@gmail.com",
                    Username = "admin",
                    PasswordHash = adminHash,
                    PasswordSalt = Convert.ToBase64String(adminSalt),
                    Role = UserRole.Admin,
                    IsActive = true,
                    IsEmailVerified = true,
                    DateCreated = DateTime.UtcNow
                };

                _context.Users.Add(adminUser);

                // Create a veterinarian user for testing
                var vetPassword = "Sifra123!";
                var vetHash = _hashingService.HashPassword(vetPassword, out byte[] vetSalt);

                var vetUser = new User
                {
                    FirstName = "Izel",
                    LastName = "User",
                    Email = "izel.repuh@edu.fit.ba",
                    Username = "drsmith",
                    PasswordHash = vetHash,
                    PasswordSalt = Convert.ToBase64String(vetSalt),
                    Role = UserRole.Veterinarian,
                    IsActive = true,
                    IsEmailVerified = true,
                    DateCreated = DateTime.UtcNow,
                    LicenseNumber = "VET-2024-001",
                    Specialization = "General Practice",
                    YearsOfExperience = 10,
                    Biography = "Experienced veterinarian with a passion for animal care.",
                    WorkStartTime = new TimeSpan(8, 0, 0), // 8:00 AM
                    WorkEndTime = new TimeSpan(18, 0, 0),  // 6:00 PM
                    WorkDays = "Monday,Tuesday,Wednesday,Thursday,Friday"
                };

                _context.Users.Add(vetUser);

                // Create a mobile user (pet owner) for testing
                var mobilePassword = "Mobile123!";
                var mobileHash = _hashingService.HashPassword(mobilePassword, out byte[] mobileSalt);

                var mobileUser = new User
                {
                    FirstName = "Jane",
                    LastName = "Doe",
                    Email = "petowner@email.com",
                    Username = "janedoe",
                    PasswordHash = mobileHash,
                    PasswordSalt = Convert.ToBase64String(mobileSalt),
                    Role = UserRole.PetOwner,
                    IsActive = true,
                    IsEmailVerified = true,
                    DateCreated = DateTime.UtcNow,
                    PhoneNumber = "+1234567890",
                    Address = "123 Pet Street, Animal City"
                };

                _context.Users.Add(mobileUser);

                await _context.SaveChangesAsync();

                _logger.LogInformation("Default users seeded successfully:");
                _logger.LogInformation("Admin - Email: izellapin@gmail.com, Password: Admin123!");
                _logger.LogInformation("Veterinarian - Email: izel.repuh@edu.fit.ba, Password: Vet123!");
                _logger.LogInformation("Pet Owner - Email: petowner@email.com, Password: Mobile123!");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error seeding admin user");
                throw;
            }
        }

        public async Task SeedCategoriesAsync()
        {
            try
            {
                // Check if categories already exist
                if (await _context.Categories.AnyAsync())
                {
                    _logger.LogInformation("Categories already exist, skipping category seeding");
                    return;
                }

                var categories = new[]
                {
                    new Category
                    {
                        Name = "Wellness & Prevention",
                        Description = "Preventive care and wellness services",
                        CategoryType = "Medical",
                        TargetSpecies = "All",
                        IsActive = true,
                        DateCreated = DateTime.UtcNow,
                        SortOrder = 1
                    },
                    new Category
                    {
                        Name = "Emergency Care",
                        Description = "Emergency and urgent care services",
                        CategoryType = "Emergency",
                        TargetSpecies = "All",
                        IsActive = true,
                        DateCreated = DateTime.UtcNow,
                        SortOrder = 2
                    },
                    new Category
                    {
                        Name = "Surgery",
                        Description = "Surgical procedures and operations",
                        CategoryType = "Surgical",
                        TargetSpecies = "All",
                        IsActive = true,
                        DateCreated = DateTime.UtcNow,
                        SortOrder = 3
                    },
                    new Category
                    {
                        Name = "Dental Care",
                        Description = "Dental cleaning and oral health services",
                        CategoryType = "Medical",
                        TargetSpecies = "All",
                        IsActive = true,
                        DateCreated = DateTime.UtcNow,
                        SortOrder = 4
                    },
                    new Category
                    {
                        Name = "Grooming",
                        Description = "Pet grooming and hygiene services",
                        CategoryType = "Grooming",
                        TargetSpecies = "All",
                        IsActive = true,
                        DateCreated = DateTime.UtcNow,
                        SortOrder = 5
                    }
                };

                _context.Categories.AddRange(categories);
                await _context.SaveChangesAsync();

                _logger.LogInformation($"Seeded {categories.Length} categories successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error seeding categories");
                throw;
            }
        }

        public async Task SeedServicesAsync()
        {
            try
            {
                // Check if services already exist
                if (await _context.Services.AnyAsync())
                {
                    _logger.LogInformation("Services already exist, skipping service seeding");
                    return;
                }

                // Get categories for foreign key references (use FirstOrDefault to avoid crashes)
                var wellnessCategory = await _context.Categories.FirstOrDefaultAsync(c => c.Name == "Wellness & Prevention");
                var emergencyCategory = await _context.Categories.FirstOrDefaultAsync(c => c.Name == "Emergency Care");
                var surgeryCategory = await _context.Categories.FirstOrDefaultAsync(c => c.Name == "Surgery");
                var dentalCategory = await _context.Categories.FirstOrDefaultAsync(c => c.Name == "Dental Care");
                var groomingCategory = await _context.Categories.FirstOrDefaultAsync(c => c.Name == "Grooming");

                // If categories don't exist, use the first available category or create a default one
                var defaultCategory = wellnessCategory ?? emergencyCategory ?? surgeryCategory ?? dentalCategory ?? groomingCategory;
                if (defaultCategory == null)
                {
                    // Get any existing category
                    defaultCategory = await _context.Categories.FirstOrDefaultAsync();
                    if (defaultCategory == null)
                    {
                        _logger.LogWarning("No categories found for services. Skipping service seeding.");
                        return;
                    }
                }

                // Use default category for missing ones
                wellnessCategory ??= defaultCategory;
                emergencyCategory ??= defaultCategory;
                surgeryCategory ??= defaultCategory;
                dentalCategory ??= defaultCategory;
                groomingCategory ??= defaultCategory;

                var services = new[]
                {
                    // Wellness services
                    new Service
                    {
                        Name = "Annual Wellness Exam",
                        Code = "WELLNESS-001",
                        Description = "Comprehensive annual health examination for your pet",
                        ShortDescription = "Complete health checkup",
                        Price = 75.00m,
                        DurationMinutes = 45,
                        RequiresAppointment = true,
                        ServiceType = "Wellness Exam",
                        AgeGroup = "All",
                        CategoryId = wellnessCategory.Id,
                        IsActive = true,
                        DateCreated = DateTime.UtcNow
                    },
                    new Service
                    {
                        Name = "Vaccination Package",
                        Code = "WELLNESS-002",
                        Description = "Essential vaccinations to protect your pet from diseases",
                        ShortDescription = "Core vaccinations",
                        Price = 120.00m,
                        DurationMinutes = 30,
                        RequiresAppointment = true,
                        ServiceType = "Vaccination",
                        AgeGroup = "All",
                        CategoryId = wellnessCategory.Id,
                        IsActive = true,
                        DateCreated = DateTime.UtcNow
                    },
                    // Emergency services
                    new Service
                    {
                        Name = "Emergency Consultation",
                        Code = "EMERGENCY-001",
                        Description = "Urgent medical consultation for emergency situations",
                        ShortDescription = "Emergency care",
                        Price = 150.00m,
                        DurationMinutes = 60,
                        RequiresAppointment = false,
                        ServiceType = "Emergency",
                        AgeGroup = "All",
                        CategoryId = emergencyCategory.Id,
                        IsActive = true,
                        DateCreated = DateTime.UtcNow
                    },
                    // Surgery services
                    new Service
                    {
                        Name = "Spay/Neuter Surgery",
                        Code = "SURGERY-001",
                        Description = "Surgical sterilization procedure",
                        ShortDescription = "Spay/Neuter operation",
                        Price = 300.00m,
                        DurationMinutes = 120,
                        RequiresAppointment = true,
                        RequiresFasting = true,
                        ServiceType = "Surgery",
                        AgeGroup = "Adult",
                        PreparationInstructions = "Fast for 12 hours before surgery",
                        PostCareInstructions = "Keep incision dry and monitor for 10-14 days",
                        CategoryId = surgeryCategory.Id,
                        IsActive = true,
                        DateCreated = DateTime.UtcNow
                    },
                    // Dental services
                    new Service
                    {
                        Name = "Dental Cleaning",
                        Code = "DENTAL-001",
                        Description = "Professional dental cleaning and oral health assessment",
                        ShortDescription = "Teeth cleaning",
                        Price = 200.00m,
                        DurationMinutes = 90,
                        RequiresAppointment = true,
                        RequiresFasting = true,
                        ServiceType = "Dental",
                        AgeGroup = "Adult",
                        PreparationInstructions = "Fast for 8 hours before procedure",
                        CategoryId = dentalCategory.Id,
                        IsActive = true,
                        DateCreated = DateTime.UtcNow
                    },
                    // Grooming services
                    new Service
                    {
                        Name = "Full Grooming Package",
                        Code = "GROOMING-001",
                        Description = "Complete grooming service including bath, nail trim, and styling",
                        ShortDescription = "Full grooming",
                        Price = 80.00m,
                        DurationMinutes = 120,
                        RequiresAppointment = true,
                        ServiceType = "Grooming",
                        AgeGroup = "All",
                        CategoryId = groomingCategory.Id,
                        IsActive = true,
                        DateCreated = DateTime.UtcNow
                    }
                };

                _context.Services.AddRange(services);
                await _context.SaveChangesAsync();

                _logger.LogInformation($"Seeded {services.Length} services successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error seeding services");
                throw;
            }
        }
    }
}
