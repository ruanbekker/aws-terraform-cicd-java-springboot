package com.ruanbekker.cargarage.controller;

import com.ruanbekker.cargarage.exception.ResourceNotFoundException;
import com.ruanbekker.cargarage.model.Car;
import com.ruanbekker.cargarage.repository.CarRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api")
public class CarController {

    @Autowired
    CarRepository carRepository;

    @GetMapping("/cars")
    public List<Car> getAllCars() {
        return carRepository.findAll();
    }

    @PostMapping("/cars")
    public Car createCar(@Valid @RequestBody Car car) {
        return carRepository.save(car);
    }

    @GetMapping("/cars/{id}")
    public Car getCarById(@PathVariable(value = "id") Long carId) {
        return carRepository.findById(carId)
                .orElseThrow(() -> new ResourceNotFoundException("Car", "id", carId));
    }

    @PutMapping("/cars/{id}")
    public Car updateCar(@PathVariable(value = "id") Long carId, @Valid @RequestBody Car carDetails) {

        Car car = carRepository.findById(carId).orElseThrow(() -> new ResourceNotFoundException("Car", "id", carId));
        car.setMake(carDetails.getMake());
        car.setModel(carDetails.getModel());
        Car updatedCar = carRepository.save(car);
        
        return updatedCar;
    }

    @DeleteMapping("/cars/{id}")
    public ResponseEntity<?> deleteCar(@PathVariable(value = "id") Long carId) {
        Car car = carRepository.findById(carId).orElseThrow(() -> new ResourceNotFoundException("Car", "id", carId));
        carRepository.delete(car);

        return ResponseEntity.ok().build();
    }
}