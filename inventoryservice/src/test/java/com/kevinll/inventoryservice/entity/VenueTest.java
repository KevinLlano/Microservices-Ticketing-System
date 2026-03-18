package com.kevinll.inventoryservice.entity;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class VenueTest {

    @Test
    void testVenueImmutability() {
        // Create a Venue object
        Venue venue = new Venue(1L, "Main Hall", "123 Main St", 500L);

        // Check that fields are set correctly
        assertEquals(1L, venue.getId());
        assertEquals("Main Hall", venue.getName());
        assertEquals("123 Main St", venue.getAddress());
        assertEquals(500L, venue.getTotalCapacity());

        // The following lines would not compile (uncomment to see error):
        // venue.setName("New Name");
        // venue.id = 2L;
        // There are no setters, and fields are final, so object is immutable.


    }
}

