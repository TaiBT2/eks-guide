package com.example.springbootk8sdemo.controller;

import com.example.springbootk8sdemo.model.User;
import com.example.springbootk8sdemo.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    // Display all users
    @GetMapping
    public String getAllUsers(Model model, @RequestParam(required = false) String search) {
        List<User> users;
        if (search != null && !search.trim().isEmpty()) {
            users = userService.searchUsersByName(search);
            model.addAttribute("search", search);
        } else {
            users = userService.getAllUsers();
        }
        model.addAttribute("users", users);
        return "users/list";
    }
    
    // Show create user form
    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("user", new User());
        return "users/form";
    }
    
    // Create new user
    @PostMapping
    public String createUser(@Valid @ModelAttribute User user, 
                           BindingResult result, 
                           RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            return "users/form";
        }
        
        // Check if email already exists
        if (userService.emailExists(user.getEmail())) {
            result.rejectValue("email", "error.user", "Email already exists");
            return "users/form";
        }
        
        userService.saveUser(user);
        redirectAttributes.addFlashAttribute("successMessage", "User created successfully!");
        return "redirect:/users";
    }
    
    // Show user details
    @GetMapping("/{id}")
    public String getUserById(@PathVariable Long id, Model model) {
        Optional<User> user = userService.getUserById(id);
        if (user.isPresent()) {
            model.addAttribute("user", user.get());
            return "users/detail";
        } else {
            redirectAttributes.addFlashAttribute("errorMessage", "User not found");
            return "redirect:/users";
        }
    }
    
    // Show edit user form
    @GetMapping("/{id}/edit")
    public String showEditForm(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        Optional<User> user = userService.getUserById(id);
        if (user.isPresent()) {
            model.addAttribute("user", user.get());
            return "users/form";
        } else {
            redirectAttributes.addFlashAttribute("errorMessage", "User not found");
            return "redirect:/users";
        }
    }
    
    // Update user
    @PostMapping("/{id}")
    public String updateUser(@PathVariable Long id, 
                           @Valid @ModelAttribute User user, 
                           BindingResult result, 
                           RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            return "users/form";
        }
        
        // Check if email exists for other user
        if (userService.emailExistsForOtherUser(user.getEmail(), id)) {
            result.rejectValue("email", "error.user", "Email already exists");
            return "users/form";
        }
        
        User updatedUser = userService.updateUser(id, user);
        if (updatedUser != null) {
            redirectAttributes.addFlashAttribute("successMessage", "User updated successfully!");
        } else {
            redirectAttributes.addFlashAttribute("errorMessage", "User not found");
        }
        return "redirect:/users";
    }
    
    // Delete user
    @PostMapping("/{id}/delete")
    public String deleteUser(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        boolean deleted = userService.deleteUser(id);
        if (deleted) {
            redirectAttributes.addFlashAttribute("successMessage", "User deleted successfully!");
        } else {
            redirectAttributes.addFlashAttribute("errorMessage", "User not found");
        }
        return "redirect:/users";
    }
    
    // Search users
    @GetMapping("/search")
    public String searchUsers(@RequestParam String query, Model model) {
        List<User> users = userService.searchUsersByName(query);
        model.addAttribute("users", users);
        model.addAttribute("search", query);
        return "users/list";
    }
}
