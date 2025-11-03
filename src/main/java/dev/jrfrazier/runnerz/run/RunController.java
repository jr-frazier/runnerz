package dev.jrfrazier.runnerz.run;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/runs")
public class RunController {

    private final RunRepository runRepository;

    public RunController(RunRepository runRepository) {
        this.runRepository = runRepository;
    }

    @GetMapping("")
    List<Run> getRuns() {
        return runRepository.findAll();
    }

    @GetMapping("/{id}")
    Run findById(@PathVariable Integer id) {

        Optional<Run> run = runRepository.findById(id);

        if(run.isEmpty() ) {
           throw new RunNotFoundException();
        }

        return run.get();
    }

    //post
    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping("")
    Run createRun(@Valid @RequestBody Run run) {
        runRepository.save(run);
        return run;
    }

    //put
    @ResponseStatus(HttpStatus.OK)
    @PutMapping("/{id}")
    Run updateRun(@Valid @RequestBody Run run, @PathVariable Integer id) {
        Optional<Run> existingRun = runRepository.findById(id);
        if(existingRun.isEmpty()) {
            throw new RunNotFoundException();
        }
        runRepository.save(run);
        return run;
    }

    //delete
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @DeleteMapping("/{id}")
    void deleteRun(@PathVariable Integer id) {
        Optional<Run> existingRun = runRepository.findById(id);
        if(existingRun.isEmpty()) {
            throw new RunNotFoundException();
        }
        runRepository.delete(runRepository.findById(id).get());
    }

    @GetMapping("/location/{location}")
    List<Run> findByLocation(@PathVariable String location) {
        return runRepository.findAllByLocation(location);
    }
}