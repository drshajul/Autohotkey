var strings = new Object();

if(navigator.browserLanguage){
  lang = navigator.browserLanguage;
}else{
  lang = navigator.language;
}

lang = lang.substr(0,2).toLowerCase();

lang="en";

if(lang=='de'){/////////////////////////////German////////////////////////////////////////////////////


strings["Contents"]                              = "Inhalt";
strings["Index"]                                 = "Index";
strings["Search"]                                = "Suche";
strings["Bookmark"]                              = "Lesezeichen";

strings["Loading the data for search..."]        = "Laden der Daten für die Suche ...";
strings["Type in the word(s) to search for:"]    = "Geben Sie das Wort für die Suche nach:";
strings["Search title only"]                     = "Suche Titel nur";
strings["Search previous results"]               = "Suche frühere Resultate";
strings["Display"]                               = "Anzeige";
strings["No topics found!"]                      = "Keine Themen gefunden!";

strings["Type in the keyword to find:"]          = "Geben Sie das Stichwort zu finden:";

strings["Show all"]                              = "Alle anzeigen";
strings["Hide all"]                              = "Alle ausblenden";
strings["Previous"]                              = "Zurück";
strings["Next"]                                  = "Weiter";

strings["Loading table of contents..."]          = "Lade Inhaltsverzeichnis ...";

strings["Topics:"]                               = "Themen";
strings["Current topic:"]                        = "Aktuelles Thema:";
strings["Remove"]                                = "Entfernen";
strings["Add"]                                   = "Hinzufügen";


}else if(lang=='fr'){///////////////////////French/////////////////////////////////////////////////////////////

strings["Contents"]                              = "Contenu";
strings["Index"]                                 = "Index";
strings["Search"]                                = "Rechercher";
strings["Bookmark"]                              = "Signet";

strings["Loading the data for search..."]        = "Chargement des données pour la recherche ...";
strings["Type in the word(s) to search for:"]    = "Tapez le mot à rechercher:";
strings["Search title only"]                     = "Rechercher dans les titres seulement";
strings["Search previous results"]               = "Rechercher résultats précédents";
strings["Display"]                               = "Afficher";
strings["No topics found!"]                      = "Pas de sujets trouvés!";

strings["Type in the keyword to find:"]          = "Entrez le mot-clé à trouver:";

strings["Show all"]                              = "Afficher tout";
strings["Hide all"]                              = "Masquer tous";
strings["Previous"]                              = "Précédent";
strings["Next"]                                  = "Suivant";

strings["Loading table of contents..."]          = "Chargement table des matières..."; 

strings["Topics:"]                               = "Thèmes";
strings["Current topic:"]                        = "Current topic:";
strings["Remove"]                                = "Supprimer";
strings["Add"]                                   = "Ajouter";


}else if(lang=='nl'){//////////////////////////Dutch//////////////////////////////////////////////////////////

strings["Contents"]                              = "Inhoud";
strings["Index"]                                 = "Index";
strings["Search"]                                = "Zoeken";
strings["Bookmark"]                              = "Favorieten";

strings["Loading the data for search..."]        = "Het laden van de gegevens voor zoek ...";
strings["Type in the word(s) to search for:"]    = "Typ het woord in om te zoeken naar:";
strings["Search title only"]                     = "Zoeken in titels alleen";
strings["Search previous results"]               = "Zoeken vorige resultaten";
strings["Display"]                               = "Weergave";
strings["No topics found!"]                      = "Geen onderwerpen gevonden!";

strings["Type in the keyword to find:"]          = "Typ het trefwoord te zoeken:";

strings["Show all"]                              = "Toon alle";
strings["Hide all"]                              = "Alles verbergen";
strings["Previous"]                              = "Vorige";
strings["Next"]                                  = "Volgende";

strings["Loading table of contents..."]          = "Laden inhoudsopgave ...";

strings["Topics:"]                               = "Onderwerpen";
strings["Current topic:"]                        = "Huidig onderwerp:";
strings["Remove"]                                = "Verwijder";
strings["Add"]                                   = "Voeg toe";


}else if(lang=='it'){//////////////////////////Italian////////////////////////////////////////////////

strings["Contents"]                              = "Contenuti";
strings["Index"]                                 = "Indice";
strings["Search"]                                = "Cerca";
strings["Bookmark"]                              = "Segnalibro";

strings["Loading the data for search..."]        = "Caricamento dei dati per la ricerca ...";
strings["Type in the word(s) to search for:"]    = "Inserisci la parola per la ricerca di:";
strings["Search title only"]                     = "Cerca solo titolo";
strings["Search previous results"]               = "Cerca risultati precedenti";
strings["Display"]                               = "Visualizza";
strings["No topics found!"]                      = "Nessun argomenti trovato!";

strings["Type in the keyword to find:"]          = "Inserisci la parola chiave per trovare:";

strings["Show all"]                              = "Mostra tutti";
strings["Hide all"]                              = "Nascondi tutto";
strings["Previous"]                              = "Precedente";
strings["Next"]                                  = "Avanti";

strings["Loading table of contents..."]          = "Caricamento della tabella dei contenuti ...";

strings["Topics:"]                               = "Argomenti";
strings["Current topic:"]                        = "Tema attuale:";
strings["Remove"]                                = "Rimuovi";
strings["Add"]                                   = "Aggiungi";


}else if(lang=='se'){//////////////////////////Spanish////////////////////////////////////////////////

strings["Contents"]                              = "Contenidos";
strings["Index"]                                 = "Índice";
strings["Search"]                                = "Buscar";
strings["Bookmark"]                              = "Guardar";

strings["Loading the data for search..."]        = "Carga de los datos para la búsqueda ...";
strings["Type in the word(s) to search for:"]    = "Escriba la palabra (s) a buscar:";
strings["Search title only"]                     = "Buscar en el título sólo";
strings["Search previous results"]               = "Buscar en los resultados anteriores";
strings["Display"]                               = "Mostrar";
strings["No topics found!"]                      = "No hay temas encontrado!";

strings["Type in the keyword to find:"]          = "Escribir la palabra clave para buscar:";

strings["Show all"]                              = "Mostrar todos";
strings["Hide all"]                              = "Ocultar todos";
strings["Previous"]                              = "Anterior";
strings["Next"]                                  = "Siguiente";

strings["Loading table of contents..."]          = "Carga de la tabla de contenido ...";

strings["Topics:"]                               = "Temas";
strings["Current topic:"]                        = "Tema actual:";
strings["Remove"]                                = "Eliminar";
strings["Add"]                                   = "Añadir";


}else{//////////////////////////////////////English///////////////////////////////////////////////////

strings["Contents"]                              ="Contents";
strings["Index"]                                 ="Index";
strings["Search"]                                ="Search";
strings["Bookmark"]                              ="Bookmark";

strings["Loading the data for search..."]        ="Loading the data for search...";
strings["Type in the word(s) to search for:"]    ="Type in the word(s) to search for:";
strings["Search title only"]                     ="Search title only";
strings["Search previous results"]               ="Search previous results";
strings["Display"]                               ="Display";
strings["No topics found!"]                      ="No topics found!";

strings["Type in the keyword to find:"]          ="Type in the keyword to find:";

strings["Show all"]                              ="Show all";
strings["Hide all"]                              ="Hide all";
strings["Previous"]                              ="Previous";
strings["Next"]                                  ="Next";

strings["Loading table of contents..."]          ="Loading table of contents...";

strings["Topics:"]                               ="Topics";
strings["Current topic:"]                        ="Current topic:";
strings["Remove"]                                ="Remove";
strings["Add"]                                   ="Add";

}

