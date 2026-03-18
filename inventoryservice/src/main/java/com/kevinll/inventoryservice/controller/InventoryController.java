package com.kevinll.inventoryservice.controller;


import com.kevinll.inventoryservice.response.EventInventoryResponse;
import com.kevinll.inventoryservice.response.VenueInventoryResponse;
import com.kevinll.inventoryservice.service.InventoryServiceInterface;
import jakarta.validation.constraints.Positive;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@Validated
@RestController
@RequestMapping("/api/v1")
public class InventoryController {

    private final InventoryServiceInterface inventoryService;

    @Autowired
    public InventoryController(final InventoryServiceInterface inventoryService) {
        this.inventoryService = inventoryService;
    }

    @GetMapping("/inventory/events")
    public @ResponseBody List<EventInventoryResponse> inventoryGetAllEvents() {
        return inventoryService.getAllEvents();
    }

    @GetMapping("/inventory/venue/{venueId}")
    public @ResponseBody VenueInventoryResponse inventoryByVenueId(@PathVariable("venueId") @Positive Long venueId) {
        return inventoryService.getVenueInformation(venueId);
    }

    @GetMapping("inventory/event/{eventId}")
    public @ResponseBody EventInventoryResponse inventoryForEvent(@PathVariable("eventId") @Positive Long eventId) {
        return inventoryService.getEventInventory(eventId);
    }

    @PutMapping("/inventory/event/{eventId}/capacity/{capacity}")
    public ResponseEntity<Void> updateEventCapacity(@PathVariable("eventId") @Positive Long eventId, @PathVariable("capacity") @Positive Long ticketsBooked) {
        inventoryService.updateEventCapacity(eventId, ticketsBooked);
        return ResponseEntity.ok().build();
    }


}
