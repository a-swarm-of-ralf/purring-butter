:- module(ontology_reader, []).

:- use_module(library(debug)).
:- use_module(library(semweb/turtle)).
:- use_module(library(semweb/rdf11)).


%%
%% Load ontology from specified file.
%%
load_ontology_file(Graph, File) :-
    debug(info, 'loading ontology \'~w\'...', [File]),
    open(File, read, Stream),
    debug(info, '~w file opened', [File]),
    call_cleanup(rdf_read_turtle(stream(Stream), Triples, [ prefixes(Prefixes) ]), close(Stream)),
    debug(info, '~w file closed.', [File]),
    load_prefixes(Prefixes),
    load_triples(Graph, Triples).

%%
%% Presist prefixes
%%
load_prefixes([]).
load_prefixes([ Prefix-Uri | Rest ]) :-
    debug(info, 'loading prefix \'~w\' - <~w>...', [Prefix, Uri]),
    rdf_register_prefix(Prefix, Uri, [keep(true)]),
    load_prefixes(Rest).

%%
%% Persist the triples to Graph.
%%
load_triples(_Graph, []).
load_triples(Graph, [ rdf(S, P, literal(type(TypeIRI, O))) | Rest ]) :-
    !,
    debug(load_triples/info, 'loading triple \'~w\'...', [S]),
    debug(load_triples/info, '               \'~w\'...', [P]),
    debug(load_triples/info, '               literal \'~w\' of type <~w>...', [O, TypeIRI]),
    rdf_assert(S, P, O^^TypeIRI, Graph),
    load_triples(Graph, Rest).
load_triples(Graph, [ rdf(S, P, literal(O)) | Rest ]) :-
    !,
    debug(load_triples/info, 'loading triple \'~w\'...', [S]),
    debug(load_triples/info, '               \'~w\'...', [P]),
    debug(load_triples/info, '               literal \'~w\'...', [O]),
    rdf_assert(S, P, O^^'http://www.w3.org/2001/XMLSchema#string', Graph),
    load_triples(Graph, Rest).
load_triples(Graph, [ rdf(S, P, O) | Rest ]) :-
    !,
    debug(load_triples/info, 'loading triple \'~w\'...', [S]),
    debug(load_triples/info, '               \'~w\'...', [P]),
    debug(load_triples/info, '               \'~w\'...', [O]),
    rdf_assert(S, P, O, Graph),
    load_triples(Graph, Rest).
load_triples(Graph, [ rdf(S, P, O, G ) | Rest ]) :-
    !,
    debug(load_triples/info, 'loading quad as triple discarding graph \'~w\'...', [G]),
    load_triples(Graph, [ rdf(S, P, O) | Rest ]).

%%
%% Reads a triple from the database
%%
read_rdf(G, S, P, O) :- 
    debug(info, 'reading literal believe \'~w\' - \'~w\' - \'~w\'...', [S, P, O]),
    rdf(S, P, ^^(O, _Type), G),
    debug(info, 'read believe \'~w\' - \'~w\' - \'~w\'.', [S, P, O]).
read_rdf(G, S, P, O) :- 
    debug(info, 'reading literal string believe \'~w\' - \'~w\' - \'~w\'...', [S, P, O]),
    rdf(S, P, @(O, _Lang), G),
    debug(info, 'read believe \'~w\' - \'~w\' - \'~w\'.', [S, P, O]).
read_rdf(G, S, P, O) :- 
    debug(info, 'reading believe \'~w\' - \'~w\' - \'~w\'...', [S, P, O]),
    rdf(S, P, O, G),
    debug(info, 'read believe \'~w\' - \'~w\' - \'~w\'.', [S, P, O]).

%%
%% Writes a triple to the database
%%
write_rdf(G, S, P, O) :-
    rdf_assert(S, P, O, G),
    debug(info, 'wrote believe \'~w\' - \'~w\' - \'~w\'.', [S, P, O]).

%%
%% Reads a triple from the database from the relevant graph
%%
read_believe(S, P, O) :- read_rdf(believes, S, P, O).
read_event(S, P, O) :- read_rdf(events, S, P, O).
read_action(S, P, O) :- read_rdf(actions, S, P, O).
read_intermediate(S, P, O) :- read_rdf(intermediate, S, P, O).

%%
%% Writes a triple to the database in the relevant graph
%%
write_believe(S, P, O) :- write_rdf(believes, S, P, O).
write_event(S, P, O) :- write_rdf(events, S, P, O).
write_event(S, P, O) :- write_rdf(actions, S, P, O).
write_intermediate(S, P, O) :- write_rdf(intermediate, S, P, O).



%%
%% Tests
%%
:- begin_tests(ontology_reader).

test(load_ontology_1, []) :-
    debug(ontology_reader/load/info),
    load_ontology_file('../data/ontology.ttl').    

:- end_tests(ontology_reader).