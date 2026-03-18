package com.kevinll.inventoryservice.entity;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@AllArgsConstructor
@NoArgsConstructor(force = true)
@Table(name = "venue")
public class Venue {

    @Id
    @Column(name = "id")
    private final Long id;

    @Column(name = "name")
    private final String name;

    @Column(name = "address")
    private final String address;

    @Column(name = "total_capacity")
    private final Long totalCapacity;


    // No setters: fields are immutable. Use constructor for initialization.
}
