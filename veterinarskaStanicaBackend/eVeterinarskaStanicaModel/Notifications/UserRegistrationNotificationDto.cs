using System;
using System.Collections.Generic;

namespace eVeterinarskaStanicaModel.Notifications
{
    /// <summary>
    /// DTO for user registration notifications sent via RabbitMQ
    /// </summary>
    public class UserRegistrationNotificationDto
    {
        public int UserId { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public DateTime RegistrationDate { get; set; }
        public string VerificationCode { get; set; } = string.Empty;
        public bool IsEmailVerified { get; set; }
        public string WelcomeMessage { get; set; } = string.Empty;
        public List<string> AdminEmails { get; set; } = new(); // For admin notifications
    }

    /// <summary>
    /// Wrapper class for RabbitMQ publishing
    /// </summary>
    public class UserRegistrationNotification
    {
        public UserRegistrationNotificationDto User { get; set; } = new();
    }

    /// <summary>
    /// DTO for general system notifications
    /// </summary>
    public class SystemNotificationDto
    {
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string NotificationType { get; set; } = string.Empty; // "Info", "Warning", "Error", "Success"
        public string Priority { get; set; } = "Normal"; // "Low", "Normal", "High", "Critical"
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public List<string> UserEmails { get; set; } = new();
        public List<int>? TargetUserIds { get; set; }
        public string? ActionUrl { get; set; }
        public string? ActionText { get; set; }
    }

    /// <summary>
    /// Wrapper class for RabbitMQ publishing
    /// </summary>
    public class SystemNotification
    {
        public SystemNotificationDto Notification { get; set; } = new();
    }
}