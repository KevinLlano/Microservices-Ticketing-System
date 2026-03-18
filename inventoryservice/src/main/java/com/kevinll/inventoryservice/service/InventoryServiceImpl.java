package com.kevinll.inventoryservice.service;

import com.kevinll.inventoryservice.entity.Event;
import com.kevinll.inventoryservice.entity.Venue;
import com.kevinll.inventoryservice.exception.EventNotFoundException;
import com.kevinll.inventoryservice.repository.EventRepository;
import com.kevinll.inventoryservice.repository.VenueRepository;
import com.kevinll.inventoryservice.response.EventInventoryResponse;
import com.kevinll.inventoryservice.response.VenueInventoryResponse;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Slf4j
public class InventoryServiceImpl implements InventoryServiceInterface {

    private final EventRepository eventRepository;
    private final VenueRepository venueRepository;

    @Autowired
    public InventoryServiceImpl(final EventRepository eventRepository, final VenueRepository venueRepository) {
        this.eventRepository = eventRepository;
        this.venueRepository = venueRepository;
    }

    public List<EventInventoryResponse> getAllEvents() {
        final List<Event> events = eventRepository.findAll();

        return events.stream().map(event -> EventInventoryResponse.builder()
                .event(event.getName())
                .capacity(event.getLeftCapacity())
                .venue(event.getVenue())
                .build()).collect(Collectors.toList());
    }

    public VenueInventoryResponse getVenueInformation(final Long venueId) {
        final Optional<Venue> venueOpt = venueRepository.findById(venueId);
        final Venue venue = venueOpt.orElse(null);
        return VenueInventoryResponse.builder()
                .venueId(venue != null ? venue.getId() : null)
                .venueName(venue != null ? venue.getName() : null)
                .totalCapacity(venue != null ? venue.getTotalCapacity() : null)
                .build();
    }

    public EventInventoryResponse getEventInventory(final Long eventId) {
        final Optional<Event> eventOpt = eventRepository.findById(eventId);
        final Event event = eventOpt.orElseThrow(() -> new EventNotFoundException(eventId));
        return EventInventoryResponse.builder()
                .event(event.getName())
                .capacity(event.getLeftCapacity())
                .venue(event.getVenue())
                .ticketPrice(event.getTicketPrice())
                .eventId(event.getId())
                .build();
    }

    public void updateEventCapacity(final Long eventId, final Long ticketsBooked) {
        final Optional<Event> eventOpt = eventRepository.findById(eventId);
        final Event event = eventOpt.orElseThrow(() -> new EventNotFoundException(eventId));
        event.setLeftCapacity(event.getLeftCapacity() - ticketsBooked);
        eventRepository.saveAndFlush(event);
        log.info("Updated event capacity for event id: {} with tickets booked: {}", eventId, ticketsBooked);
    }
}
