using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eVeterinarskaStanicaModel
{
    public class Review
    {
        [Key]
        public int Id { get; set; }

        [Range(1, 5)]
        public int Rating { get; set; } // 1-5 stars

        [StringLength(100)]
        public string? Title { get; set; }

        [StringLength(2000)]
        public string? Comment { get; set; }

        public DateTime DateCreated { get; set; } = DateTime.UtcNow;

        public bool IsVerifiedPurchase { get; set; } = false;

        public bool IsApproved { get; set; } = false;

        // Helpful votes
        public int HelpfulVotes { get; set; } = 0;

        // Veterinary-specific
        [StringLength(100)]
        public string? PetName { get; set; }

        [StringLength(50)]
        public string? PetSpecies { get; set; }

        // Foreign Keys
        public int ServiceId { get; set; }
        public int UserId { get; set; }
        public int? OrderId { get; set; }

        // Navigation Properties
        public virtual Service Service { get; set; }
        public virtual User User { get; set; }
        public virtual Order? Order { get; set; }
    }
}
