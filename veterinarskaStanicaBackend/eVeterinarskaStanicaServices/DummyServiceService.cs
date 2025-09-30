using eVeterinarskaStanicaModel;
using eVeterinarskaStanicaModel.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace eVeterinarskaStanicaServices
{
    public class DummyServiceService : iServiceService
    {
        public virtual List<Service> Get(ServiceSearchObject search)
        {
            List<Service> services = new List<Service>();
            services.Add(new Service()
            {
                Id = 1,
                Code = "CONSULT",
                Name = "General Consultation",
                Description = "Comprehensive health examination for pets",
                ShortDescription = "General pet health checkup",
                Price = 50.00m,
                ServiceType = "Consultation",
                DurationMinutes = 30,
                RequiresAppointment = true,
                IsActive = true,
                CategoryId = 1
            });
            
            services.Add(new Service()
            {
                Id = 2,
                Code = "VACC",
                Name = "Vaccination",
                Description = "Annual vaccination for dogs and cats",
                ShortDescription = "Pet vaccination service",
                Price = 75.00m,
                ServiceType = "Vaccination",
                DurationMinutes = 15,
                RequiresAppointment = true,
                IsActive = true,
                CategoryId = 1
            });

            services.Add(new Service()
            {
                Id = 3,
                Code = "GROOM",
                Name = "Pet Grooming",
                Description = "Complete grooming service including bath, nail trimming, and hair cut",
                ShortDescription = "Professional pet grooming",
                Price = 40.00m,
                ServiceType = "Grooming",
                DurationMinutes = 60,
                RequiresAppointment = true,
                IsActive = true,
                CategoryId = 2
            });

            services.Add(new Service()
            {
                Id = 4,
                Code = "EMERG",
                Name = "Emergency Care",
                Description = "24/7 emergency veterinary care",
                ShortDescription = "Emergency veterinary services",
                Price = 150.00m,
                ServiceType = "Emergency",
                DurationMinutes = 120,
                RequiresAppointment = false,
                IsActive = true,
                CategoryId = 3
            });

            var queryable = services.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search?.Code))
            {
                queryable = queryable.Where(x => x.Code == search.Code);
            }

            if (!string.IsNullOrWhiteSpace(search?.CodeGTE))
            {
                queryable = queryable.Where(x => x.Code.StartsWith(search.CodeGTE));
            }

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                queryable = queryable.Where(x => x.Code.Contains(search.FTS, StringComparison.CurrentCultureIgnoreCase) || 
                                               (x.Name != null && x.Name.Contains(search.FTS, StringComparison.CurrentCultureIgnoreCase)) ||
                                               (x.Description != null && x.Description.Contains(search.FTS, StringComparison.CurrentCultureIgnoreCase)));
            }

            if (!string.IsNullOrWhiteSpace(search?.ServiceType))
            {
                queryable = queryable.Where(x => x.ServiceType.Contains(search.ServiceType, StringComparison.CurrentCultureIgnoreCase));
            }

            if (search?.RequiresAppointment.HasValue == true)
            {
                queryable = queryable.Where(x => x.RequiresAppointment == search.RequiresAppointment.Value);
            }

            if (search?.MinPrice.HasValue == true)
            {
                queryable = queryable.Where(x => x.Price >= search.MinPrice.Value);
            }

            if (search?.MaxPrice.HasValue == true)
            {
                queryable = queryable.Where(x => x.Price <= search.MaxPrice.Value);
            }

            if (search?.CategoryId.HasValue == true)
            {
                queryable = queryable.Where(x => x.CategoryId == search.CategoryId.Value);
            }

            if (search?.IsActive.HasValue == true)
            {
                queryable = queryable.Where(x => x.IsActive == search.IsActive.Value);
            }

            if (search?.IsFeatured.HasValue == true)
            {
                queryable = queryable.Where(x => x.IsFeatured == search.IsFeatured.Value);
            }

            return queryable.ToList();
        }


        public virtual Service Get(int id)
        {
            var services = Get(new ServiceSearchObject());
            return services.FirstOrDefault(x => x.Id == id) ?? new Service()
            {
                Id = 1,
                Code = "CONSULT",
                Name = "General Consultation",
                Description = "Comprehensive health examination for pets",
                ShortDescription = "General pet health checkup",
                Price = 50.00m,
                ServiceType = "Consultation",
                DurationMinutes = 30,
                RequiresAppointment = true,
                IsActive = true,
                CategoryId = 1
            };
        }
    }
}




