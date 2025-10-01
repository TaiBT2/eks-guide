package com.example.springbootk8sdemo.repository;

import com.example.springbootk8sdemo.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Find users by name (case insensitive)
    List<User> findByNameContainingIgnoreCase(String name);
    
    // Find user by email
    User findByEmail(String email);
    
    // Find users by phone
    List<User> findByPhone(String phone);
    
    // Custom query to find users by address
    @Query("SELECT u FROM User u WHERE u.address LIKE %:address%")
    List<User> findByAddressContaining(@Param("address") String address);
    
    // Count users by name pattern
    @Query("SELECT COUNT(u) FROM User u WHERE u.name LIKE %:name%")
    long countByNameContaining(@Param("name") String name);
}
