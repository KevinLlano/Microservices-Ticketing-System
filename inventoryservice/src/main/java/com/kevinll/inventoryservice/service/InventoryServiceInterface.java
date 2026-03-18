package com.kevinll.inventoryservice.service;

import com.kevinll.inventoryservice.response.EventInventoryResponse;
import com.kevinll.inventoryservice.response.VenueInventoryResponse;
import java.util.List;

public interface InventoryServiceInterface {
    List<EventInventoryResponse> getAllEvents();
    VenueInventoryResponse getVenueInformation(Long venueId);
    EventInventoryResponse getEventInventory(Long eventId);
    void updateEventCapacity(Long eventId, Long ticketsBooked);
}

