package com.example.springbootk8sdemo.service;

import com.example.springbootk8sdemo.model.User;
import com.example.springbootk8sdemo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    // Get all users
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
    
    // Get user by ID
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }
    
    // Save user
    public User saveUser(User user) {
        return userRepository.save(user);
    }
    
    // Update user
    public User updateUser(Long id, User userDetails) {
        Optional<User> optionalUser = userRepository.findById(id);
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            user.setName(userDetails.getName());
            user.setEmail(userDetails.getEmail());
            user.setPhone(userDetails.getPhone());
            user.setAddress(userDetails.getAddress());
            return userRepository.save(user);
        }
        return null;
    }
    
    // Delete user
    public boolean deleteUser(Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return true;
        }
        return false;
    }
    
    // Search users by name
    public List<User> searchUsersByName(String name) {
        return userRepository.findByNameContainingIgnoreCase(name);
    }
    
    // Get user by email
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }
    
    // Search users by address
    public List<User> searchUsersByAddress(String address) {
        return userRepository.findByAddressContaining(address);
    }
    
    // Check if email exists
    public boolean emailExists(String email) {
        return userRepository.findByEmail(email) != null;
    }
    
    // Check if email exists for other user (for updates)
    public boolean emailExistsForOtherUser(String email, Long userId) {
        User user = userRepository.findByEmail(email);
        return user != null && !user.getId().equals(userId);
    }
}
