javascript: (() => {
    wh='https://api.aolccbc.com/webhook/c37060f1-3da9-4d8b-849f-37764b6cf14a';
    a=document.getElementById("ctl00_cphMain_Contact1_HeaderTable") ;
    studentName = a.getElementsByTagName('td')[0].innerText ;
    currentURL = window.location.href;
    campus = document.getElementsByName("ctl00$cphMain$Contact1$SectionList$ctl00$FieldList$ctl02$campusid")[0];
    campus = campus.options[campus.selectedIndex].innerText;
    fetch(`${wh}?studentName=${studentName}&currentURL=${currentURL}&campus=${campus}`,%20{%20%20%20%20%20method:%20%27POST%27,%20%20%20%20%20headers:%20{%20%20%20%20%20%20%20%20%20%27Content-Type%27:%20%27application/json%27%20%20%20%20%20},%20%20%20%20%20mode:%20%27no-cors%27%20});})();

    javascript: (() => {
        wh='https://api.aolccbc.com/webhook-test/c37060f1-3da9-4d8b-849f-37764b6cf14a';
        a=document.getElementById("ctl00_cphMain_Contact1_HeaderTable") ;
        studentName = a.getElementsByTagName('td')[0].innerText ;
        currentURL = window.location.href;
        campus = document.getElementsByName("ctl00$cphMain$Contact1$SectionList$ctl00$FieldList$ctl02$campusid")[0];
        campus = campus.options[campus.selectedIndex].innerText;
        fetch(`${wh}?studentName=${studentName}&currentURL=${currentURL}&campus=${campus}`,%20{%20%20%20%20%20method:%20%27POST%27,%20%20%20%20%20headers:%20{%20%20%20%20%20%20%20%20%20%27Content-Type%27:%20%27application/json%27%20%20%20%20%20},%20%20%20%20%20mode:%20%27no-cors%27%20});})();

