using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using eVeterinarskaStanicaServices;
using eVeterinarskaStanicaServices.Database;
using veterinarskaStanica.WebAPI.Authorization;
using eVeterinarskaStanicaModel;
using eVeterinarskaStanicaModel.Requests;
using eVeterinarskaStanicaModel.Responses;
using eVeterinarskaStanicaModel.SearchObjects;
using System.ComponentModel.DataAnnotations;

namespace veterinarskaStanica.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        // GET: api/User - Admin and Staff can view all users
        [HttpGet]
        [StaffOnly]
        public ActionResult<IEnumerable<User>> GetUsers([FromQuery] UserSearchObject? searchObject = null)
        {
            var search = searchObject ?? new UserSearchObject();
            var users = _userService.Get(search);
            return Ok(users);
        }

        // GET: api/User/5 - Staff can view any user, regular users can only view themselves
        [HttpGet("{id}")]
        [Authorize]
        public ActionResult<User> GetUser(int id)
        {
            var user = _userService.Get(id);

            if (user == null)
            {
                return NotFound();
            }

            return Ok(user);
        }

        // POST: api/User - Admin and Receptionist can create users
        [HttpPost]
        [RoleRequired(UserRole.Admin, UserRole.Receptionist)]
        public async Task<ActionResult<UserResponse>> CreateUser(UserInsertRequest request)
        {
            var result = await _userService.InsertUserAsync(request);
            
            if (!result.Success)
            {
                return BadRequest(result.ErrorMessage);
            }
            
            return CreatedAtAction(nameof(GetUser), new { id = result.Data!.Id }, result.Data);
        }

        // PUT: api/User/5
        [HttpPut("{id}")]
        public async Task<ActionResult<UserResponse>> UpdateUser(int id, UserUpdateRequest request)
        {
            var result = await _userService.UpdateUserAsync(id, request);
            
            if (!result.Success)
            {
                if (result.ErrorMessage == "User not found")
                {
                    return NotFound(result.ErrorMessage);
                }
                return BadRequest(result.ErrorMessage);
            }
            
            return Ok(result.Data);
        }

        // DELETE: api/User/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var result = await _userService.DeleteUserAsync(id);
            
            if (!result.Success)
            {
                if (result.ErrorMessage == "User not found")
                {
                    return NotFound(result.ErrorMessage);
                }
                return BadRequest(result.ErrorMessage);
            }
            
            return NoContent();
        }

        // PATCH: api/User/5/activate
        [HttpPatch("{id}/activate")]
        public async Task<IActionResult> ActivateUser(int id)
        {
            var result = await _userService.ActivateUserAsync(id);
            
            if (!result.Success)
            {
                if (result.ErrorMessage == "User not found")
                {
                    return NotFound(result.ErrorMessage);
                }
                return BadRequest(result.ErrorMessage);
            }
            
            return NoContent();
        }

        // PATCH: api/User/5/deactivate
        [HttpPatch("{id}/deactivate")]
        public async Task<IActionResult> DeactivateUser(int id)
        {
            var result = await _userService.DeactivateUserAsync(id);
            
            if (!result.Success)
            {
                if (result.ErrorMessage == "User not found")
                {
                    return NotFound(result.ErrorMessage);
                }
                return BadRequest(result.ErrorMessage);
            }
            
            return NoContent();
        }

        // POST: api/User/verify-password
        [HttpPost("verify-password")]
        public async Task<ActionResult<bool>> VerifyPassword([FromBody] VerifyPasswordRequest request)
        {
            var result = await _userService.VerifyPasswordAsync(request.Email, request.Password);
            return Ok(new { isValid = result });
        }
    }

    public class VerifyPasswordRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
}
