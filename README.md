# Agent-based implementation of Hammond's theory of organisational decision making
This model is intended to replicate the work of Hammond (1986), which illustrates theoretically that organisational behaviour does not derive solely from the design of organisational structures, nor is it completely dependent on agency (i.e., the strategic behaviour of bureaucrats working within an organisation). Rather, organisational behaviour results from the interplay of structure and agency. 

Hammond’s work advances a series of propositions, some of which are developed through thought experiments analogous to the workings of theoretical agent-based models but conducted with “pen and paper” rather than through in silico experimentation. Although this approach yields insights that remain relevant today, its ‘manual’ nature limits the number and complexity of simulations that can be conducted. This makes it difficult to estimate the likelihood of different outcomes, analyse interactions among complex organisations, and systematically explore a wide range of conditions. This study addresses these limitations by translating Hammond’s theory into an Agent-Based Model (ABM) and verifying its implementation through the successful replication of his core propositions.

The resulting model provides the foundation for a subsequent theoretical model designed to systematically explore the parameter space. Future research using this model will enable a more thorough investigation of Hammond’s theory and provide a basis for extending, and potentially challenging, the theoretical propositions he introduced.

## Instruction for use
1. Download "Hammond-org-decision-making-v1.0.0"
2. Navigate to "code" and open the file with extension ".nlogo".
3. Choose which Hammond experiment to replicate via the "Replicate-hammond-experiment" drop-down list. 
4. Load the experiment with the "Load-Hammond-experiment" button. The software will upload the experiment from the "Data" folder. 
5. Run the simulation with "go-hammond-experiments"
6. The results are saved in the "Results folder; previously existing results are overwritten

## System requirements
Runs on NetLogo 6.4

## Expected developments
Complete ODD documentation (Grimm et al., 2020)

## References

Hammond, T. H. (1986). Agenda Control, Organizational Structure, and Bureaucratic Politics. American Journal of Political Science, 30(2), 379. https://doi.org/10.2307/2111102

Grimm, V., Railsback, S. F., Vincenot, C. E., Berger, U., Gallagher, C., Deangelis, D. L., Edmonds, B., Ge, J., Giske, J., Groeneveld, J., Johnston, A. S. A., Milles, A., Nabe-Nielsen, J., Polhill, J. G., Radchuk, V., Rohwäder, M. S., Stillman, R. A., Thiele, J. C., & Ayllón, D. (2020). The ODD protocol for describing agent-based and other simulation models: A second update to improve clarity, replication, and structural realism. Journal of Artificial Societies and Social Simulation, 23(2).

