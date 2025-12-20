source("packages.R")

# --- SQLite connection ---
db <- dbConnect(RSQLite::SQLite(), "mypetshop.sqlite")

dbExecute(db, "
CREATE TABLE IF NOT EXISTS pets (
  id INTEGER PRIMARY KEY,
  name TEXT,
  type TEXT,
  age INTEGER,
  gender TEXT,
  price REAL,
  status TEXT
)
")

# Create 'pet_additional_infos' table
dbExecute(db, "
CREATE TABLE IF NOT EXISTS pet_additional_infos (
  pet_id INTEGER PRIMARY KEY,
  breed TEXT DEFAULT 'N/A',
  image TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(pet_id) REFERENCES pets(id) ON DELETE CASCADE
)
")


# ================= UI =================
ui <- fluidPage(
  style = "padding-left:0; padding-right:0;",
  useShinyFeedback(),
  useShinyjs(),
  tags$head(
    tags$link(rel="stylesheet", href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css"),
    tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"),
    
    tags$style(HTML("
    
        html, body {
      margin: 0 !important;
      padding: 0 !important;
      height: 100%;
      width: 100%;
    }
.stat-box {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 20px;
  background: linear-gradient(to left, #FFc629, #E58B2B, #E58B2B);
  border-radius: 16px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.05);
}

/* ICON ON THE LEFT */
.stat-icon {
  width: 54px;
  height: 54px;
  border-radius: 50%;
  background: #FFD700;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  color: white;
  flex-shrink: 0; /* prevents icon from shrinking */
}

/* CONTENT ON THE RIGHT */
.stat-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

/* VALUE */
.stat-number {
  font-family: PSemiBold;
  font-size: 26px;
  color: white;
  line-height: 1.1;
}

/* LABEL */
.stat-label {
  font-family: EpicPro;
  font-size: 13px;
  letter-spacing: 1px;
  color: white;
  text-transform: uppercase;
}

/* STATUS COLORS */
.stat-box.available .stat-icon {
  background: #FFD700;
}

.stat-box.purchased .stat-icon {
  background: #FFD700;
}


  @font-face {
    font-family: 'SuperAdorable';
    src: url('SuperAdorable.ttf') format('truetype');
  }

  @font-face {
    font-family: 'Poppins';
    src: url('Poppins.ttf') format('truetype');
  }

  @font-face {
    font-family: 'PMedium';
    src: url('PoppinsMedium.ttf') format('truetype');
  }

  @font-face {
    font-family: 'PSemiBold';
    src: url('PoppinsSemibold.ttf') format('truetype');
  }
  
  @font-face {
    font-family: 'PBold';
    src: url('PoppinsBold.ttf') format('truetype');
  }
  
  @font-face {
    font-family: 'EpicPro';
    src: url('EpicPro.ttf') format('truetype');
  }
  
   @font-face {
    font-family: 'FearRobot';
    src: url('FearRobot.otf') format('truetype');
  }
  
  @font-face {
    font-family: 'PExBold';
    src: url('PoppinsExtraBold.ttf') format('truetype');
  }

  body, .dataTables_wrapper, input, select, textarea {
    font-family: 'Poppins';

  }

  .dataTables_wrapper {
    font-family: 'PMedium' !important;
  }

  .btn-add {
    background-color: #7ED957;  /* dark, contrasts yellow bg */
    color: white;
    border: none;
    border-radius: 6px;
    padding: 8px 16px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
  }

  .btn-add:hover {
    background-color: #6CC44B; /* darker on hover */
    color: white !important;
  }

  .btn-update {
    background-color: #5DA9E9;
    color: white;
    border: none;
    border-radius: 50px;
    padding: 8px 10px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
  }

  .btn-update:hover {
    background-color: #4B93CF;
    color: white !important;
  }

  .btn-delete {
    background-color: #F46A6A;
    color: white;
    border: none;
    border-radius: 50px;
    padding: 8px 10px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
  }

  .btn-delete:hover, .btn-delete2:hover {
    background-color: #D85A5A;
    color: white !important;
  }
  
  .btn-delete2 {
    background-color: #F46A6A;
    color: white;
    border: none;
    padding: 8px 10px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
  }


  table.dataTable.stripe tbody tr.odd {
    background-color: #FFFDE7;
  }

  .dataTables_filter label,
  .dataTables_length label, .dataTables_wrapper .dataTables_info {
    font-weight: normal;
    color: #E58B2B !important;
    font-family:'EpicPro';
    letter-spacing: 1px;
  }
  
  .dataTables_wrapper .dataTables_paginate .paginate_button {
  color: white !important;            
  border-radius: 6px !important;
  padding: 4px 10px !important;
  margin: 0 2px !important;
  cursor: pointer;
  font-family: 'EpicPro' !important;
  transition: all 0.2s ease;
  letter-spacing: 1px;
  }
  
    .dataTables_wrapper .dataTables_paginate {
  color: white !important;            /* text color */
  font-family: 'EpicPro' !important;


  }

.dataTables_wrapper .dataTables_paginate .paginate_button,
.dataTables_wrapper .dataTables_paginate .paginate_button:hover,
.dataTables_wrapper .dataTables_paginate .paginate_button:active,
.dataTables_wrapper .dataTables_paginate .paginate_button:focus {
  background: #FFc629 !important;
  color: white !important;
}

/* Current page */
.dataTables_wrapper .dataTables_paginate .paginate_button.current {
  background-color: #e58b2b !important;
  color: white !important;
  border-color: #e58b2b !important;
}

/* Disabled buttons */
.dataTables_wrapper .dataTables_paginate .paginate_button.disabled {
  color: #999 !important;
  cursor: not-allowed !important;
  background-color: #f0f0f0 !important;
}


.dataTables_wrapper .dataTables_filter input, .dataTables_wrapper .dataTables_length select {
    background-color: #fff;     
    border: 2px solid #E58B2B !important;     
    border-radius: 10px !important;
    padding: 4px 8px;
    font-family: 'PSemiBold';
    font-size: 13px;
}

.dataTables_wrapper .dataTables_filter input:focus,
.dataTables_wrapper .dataTables_length select:focus {
    outline: none;                 /* remove default blue outline */
    border-color: #E58B2B !important;
}
  .shiny-input-container label {
    color: black;
    font-family: 'PMedium';
    font-weight: normal !important;
  }

  .btn {
    font-family: 'PSemiBold';
  }

  .dataTables_wrapper {
    font-family: 'Poppins';
    font-size: 13px;
  }
  
  table.dataTable tbody {
  background-color: white;  /* or any color you want */
}

/* Optional: keep alternating row colors */
table.dataTable.stripe tbody tr.odd {
  background-color: #FFFFFF;  /* white */
}
table.dataTable.stripe tbody tr.even {
  background-color: #FFFFE0;  /* light pastel yellow */
}


  .dataTables_wrapper .dataTable {
    border-radius: 10px;
    overflow: hidden;
  }

  table.dataTable thead th {
    background: linear-gradient(to bottom, #FFc629, #E58B2B, #E58B2B);
    color: white;
    font-family: 'EpicPro';
    border-bottom: none;
    text-transform: uppercase;
    font-weight: normal !important;
    font-size: 13px;
    letter-spacing: 1px;
  }

  #app_title {
    font-family: 'SuperAdorable', sans-serif;
    font-size: 36px;
    color: white;  /* change text color to stand out */
    text-align: center;
    width: 100%;
    height: 115px;
    padding: 40px 0;
    background-color: #ffd134;
    background-image: url('header3.png');
    background-size: auto 100%;       /* height fits container, width adjusts automatically */
    background-position: center;      /* center the image */
    background-repeat: no-repeat;     /* no repeating */
    box-shadow: 0px 2px 5px rgba(0,0,0,0.2);
    margin-bottom: 20px;
  }

  .tab-content {
  background-color:white;
  border-radius: 0 16px 8px 8px;
  padding: 20px;
  border: 4px solid #E58B2B;
  border-top: 8px solid #E58B2B;
  }
  
  .nav-tabs > li {
  margin-right: 6px;  /* adjust: 4px–10px works well */
}

  
  .nav-tabs {
  border-bottom: none; /* remove default gray bottom line */
}
  
/* All tabs */
ul.nav.nav-tabs > li > a {
  border: 4px solid #E58B2B !important;
  border-left: 8px solid #E58B2B !important;
  border-bottom: 1px solid #E58B2B !important; /* show bottom border too */
  border-radius: 12px 12px 0 0 !important;
  background-color: white !important;  /* light pastel yellow */
  color: #E58B2B !important;
  font-family: 'EpicPro';
  letter-spacing: 1px;
  margin-right: 2px !important;
  
}

/* Active tab */
ul.nav.nav-tabs > li.active > a {
  background-color: #E58B2B !important; /* gold for active */
  color: white !important;
  font-family: 'EpicPro';
  border-radius: 12px 12px 0 0 !important;
  border: 2px solid #E58B2B !important;
  letter-spacing: 1px;

}

.sidebar-panel {
  background: linear-gradient(
    to bottom,
    #ffc629,
    #e58b2b
  ) !important;
  border: none;
  border-radius: 20px 8px 8px 8px;

}
  /* === HIDE DEFAULT CHECKBOX === */
  .sidebar-panel .checkbox input[type='checkbox'] {
    display: none;  /* hide the actual checkbox */
  }
  
  /* === CONTAINER: make choices wrap === */
  .sidebar-panel .shiny-input-container {
    display: flex;       /* horizontal layout */
    flex-wrap: wrap;     /* wrap to next line if not enough space */
    gap: 8px;            /* spacing between pills */
  }
  
  /* === EACH CHECKBOX DIV INLINE === */
  .sidebar-panel .shiny-input-container .checkbox {
    display: inline-flex;   /* fit width to content */
  }

  /* === PILL BASE STYLE === */
  .sidebar-panel .checkbox label {
    display: inline-flex;
    align-items: center;
    justify-content: center;
  
    padding: 3px 14px;      /* adjusts to text */
    border-radius: 999px;    /* pill shape */
    background: transparent;
    color: white !important;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    font-family: 'PSemiBold';
    font-size: 13px;
    white-space: nowrap;
    cursor: pointer;
    user-select: none;
    border: 2px solid white;
    transition: all 0.2s ease;
  }

    /* === HOVER EFFECT === */
    .sidebar-panel .checkbox label:hover {
      transform: translateY(-1px);
      box-shadow: 0 3px 8px rgba(0,0,0,0.15);
    }
    
    /* === CHECKED STATE: FULL PILL COLOR === */
    .sidebar-panel .checkbox label:has(input:checked) {
      background: #FFD700;   /* yellow */
      color: white;          /* text color */
      border-color: #FFD700;
    }

    .sidebar-panel h4 {
      font-size: 13px;
      margin-bottom: 20px;
      color: white;
      font-family: 'FearRobot';
      position: relative;
    }

    label,
    .control-label,
    .form-label {
      color: inherit !important;
      font-weight: inherit !important;
    }

    .shiny-input-container > div > p, #m_type-text > p, #m_gender-text > p {
      font-family: 'Poppins' !important; 
      margin-top: 3px !important;
      font-size: 12px !important;
    }

  
    #modal1 .modal-header, #modal2 .modal-header, #modal3 .modal-header {
      background: linear-gradient(to left, #fcd34d, #f97316);
      padding: 15px 20px; 
      border-top-left-radius: 12px;
      border-top-right-radius: 12px;
    }
    
    #modal3 .modal-header {
      background: #F46A6A;
    }
  
    #modal1 .modal-header .modal-title, #modal2 .modal-header .modal-title, #modal3 .modal-header .modal-title {
      font-size: 2.2rem;      /* adjust as needed */
      font-family: 'EpicPro';
      letter-spacing: 1px;
      color: white;
    }
  
    #modal1 .modal-dialog {
    width: 650px;

    }
  
    #modal1 .modal-content, #modal2 .modal-content, #modal3 .modal-content {
      border-radius: 12px;
      }
    
    #modal2 .modal-dialog {
      width: 650px;
    }

    #modal2 .modal-body {
      padding: 0 !important;      
    }

    #modal1 .required-field label::after {
      content: ' *';
      color: red;
    }

  #modal1 input:focus,
  #modal1 textarea:focus,
  #modal1 .shiny-file-input:focus {
    outline: 2px solid #f97316 ;  /* orange focus ring */
    border:none !important;
    color: black;
    box-shadow: none !important;
  }
  
  #modal1 .selectize-input.focus {
  outline: 2px solid #f97316 !important;
  border: none !important;
  box-shadow: none !important;
  color: black;
}

.notif-icon {
  width: auto;
  height: 35px;
}

    .shiny-notification {
      font-family: PMedium;
      border-radius: 10px;
      padding: 10px 10px;
      font-size: 14px;
      position: fixed !important;
      border: 2px solid white;
      top: 5px !important;
      left: auto !important;
      right: 5px !important;
      bottom: auto !important;
      animation: slideInLeft 0.3s ease-out;
       min-width: 200px;  
       max-width: 400px; 
    }
    
    @keyframes slideInLeft {
      from {
        transform: translateX(40px);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }

    
    .shiny-notification-message {
      background: linear-gradient(135deg, #34d399, #10b981);
      color: white;      
      opacity: 1;
    }
    
    .shiny-notification-error {
      background: linear-gradient(135deg, #ef4444, #dc2626);
      color: white;
      opacity: 1;
    }
    
    .shiny-notification-close {
      display: none !important;
    }
    
    .login-title {
      font-size: 28px;
      color: #333;
      font-family: PBold;
    }
    
    .login-username {
      color: #f39c12;
      font-family: EpicPro;
      
    }
    
@keyframes bounceLogo {
  0% {
    transform: translateY(0) scale(1, 1);
  }

  15% {
    transform: translateY(-28px) scale(1.05, 0.95);
  }

  30% {
    transform: translateY(-35px) scale(1.03, 0.97);
  }

  45% {
    transform: translateY(0) scale(0.95, 1.05);
  }

  60% {
    transform: translateY(-12px) scale(1.02, 0.98);
  }

  80% {
    transform: translateY(0) scale(0.98, 1.02);
  }

  100% {
    transform: translateY(0) scale(1, 1);
  }
}

#animated_logo {
  animation: bounceLogo 1.4s cubic-bezier(0.34, 1.56, 0.64, 1);
  transform-origin: center bottom;
}

#login_user:focus,
#login_pass:focus {
    outline: 2px solid #f97316 ;  /* orange focus ring */
    border:none !important;
    box-shadow: none !important;
    color:black;
}

.password-wrapper {
  position: relative;
  width: 100%;
  margin-bottom: 30px;
  margin-top: 5px;
}

/* give space for the icon */
.password-wrapper input {
  padding-right: 46px;
}

/* SVG eye icon */
.eye-icon {
  position: absolute;
  right: 10px;
  top: 70%;
  transform: translateY(-50%);
  width: 18px;
  height: 18px;
  cursor: pointer;
  opacity: 0.6;
  transition: opacity 0.2s ease, transform 0.15s ease;
}

.eye-icon:hover {
  opacity: 1;
  transform: translateY(-50%) scale(1.08);
}

#login_btn {
  background-color: #eb8b2b;
  font-family: EpicPro;
  letter-spacing: 1px;
}
  
"))
    
  ),
  
  # JS to handle Cropper
  tags$script(HTML("
Shiny.addCustomMessageHandler('showImage', function(message) {
  var image = document.getElementById('cropper_preview');
  image.src = message.src;
  image.style.display = 'block';

  // Wait for modal to finish opening
  $('#modal2').on('shown.bs.modal', function () {

    if (window.cropper) {
      window.cropper.destroy();
    }

    window.cropper = new Cropper(image, {
      aspectRatio: 1,
      viewMode: 1,
      autoCropArea: 1,
      responsive: true,
      movable: true,
      zoomable: true,
      cropBoxResizable: true
    });

    // Force recalculation after animation
    setTimeout(() => {
      window.cropper.reset();
      window.cropper.resize();
    }, 50);
  });
});

$(document).on('click', '#confirm_crop', function(){
  if(window.cropper){
    var canvas = window.cropper.getCroppedCanvas({ width: 200, height: 200 });
    canvas.toBlob(function(blob){
      var reader = new FileReader();
      reader.readAsDataURL(blob);
      reader.onloadend = function() {
        Shiny.setInputValue('cropped_image', reader.result, {priority: 'event'});
        // ✅ do NOT hide modal manually
      };
    });
  } else {
    Shiny.setInputValue('cropped_image', null, {priority: 'event'});
  }
});

// Ensure body padding is cleared if modal is removed
$(document).on('hidden.bs.modal', '.modal', function () {
  $('body').removeClass('modal-open');
  $('body').css('padding-right','');
  $('.modal-backdrop').remove();
});

let showingMainLogo = true;
let bounceTimer = null;

function bounceAndSwap(img) {
  if (!img) return;

  img.style.animation = 'none';
  img.offsetHeight; // force reflow
  img.style.animation = 'bounceLogo 1.2s cubic-bezier(.34,1.56,.64,1)';

  setTimeout(() => {
    img.src = showingMainLogo ? 'logo2.png' : 'logo.png';
    showingMainLogo = !showingMainLogo;
  }, 600);
}

function startLogoLoop() {
  const img = document.getElementById('animated_logo');
  if (!img) return;

  // clear old loop
  if (bounceTimer) clearTimeout(bounceTimer);

  function loop() {
    bounceAndSwap(img);

    const delay = showingMainLogo
      ? 1500   // logo2 short
      : 6500;  // main logo long

    bounceTimer = setTimeout(loop, delay);
  }

  loop();
}

/* 🔥 Watch DOM for logo re-appearing */
const observer = new MutationObserver(() => {
  const img = document.getElementById('animated_logo');
  if (img) {
    startLogoLoop();
  }
});

observer.observe(document.body, {
  childList: true,
  subtree: true
});

document.addEventListener('click', function (e) {
  if (e.target && e.target.id === 'toggle_pass') {
    const passInput = document.getElementById('login_pass');
    if (!passInput) return;

    if (passInput.type === 'password') {
      passInput.type = 'text';
      e.target.src = 'icons/eye.svg';
    } else {
      passInput.type = 'password';
      e.target.src = 'icons/eye-slash.svg';
    }
  }
});

  document.addEventListener('click', function(event) {
    var dropdown = document.getElementById('notif_dropdown');
    var button = document.getElementById('notif_icon');
    if(dropdown && button && !dropdown.contains(event.target) && !button.contains(event.target)) {
      Shiny.setInputValue('close_notif_dropdown', Math.random());
    }
  });

")),
  uiOutput("page")
  )

  

# ================= SERVER =================
server <- function(input, output, session) {
  
  pets_data <- reactiveVal()
  pet_additional_infos_data <- reactiveVal()
  
  loadPets <- function() {
    data <- dbGetQuery(db, "SELECT * FROM pets")
    pets_data(data)  # update reactive
    return(data)     # return for assignments if needed
  }
  loadPets()
  
  loadPetAdditionalInfos <- function() {
    data <- dbGetQuery(db, "SELECT * FROM pet_additional_infos")
    pet_additional_infos_data(data)
    return(data)
  }
  loadPetAdditionalInfos()
  petIconPath <- function(type) {
    type <- tolower(type)
    
    if (type == "dog") {
      "icons/dog.svg"
    } else if (type == "cat") {
      "icons/cat.svg"
    } else if (type == "bird") {
      "icons/bird.svg"
    } else if (type == "fish") {
      "icons/fish.svg"
    } else if (type == "rabbit") {
      "icons/rabbit.svg"
    } else {
      "icons/hamster.svg"
    }
  }
  
  
  # ---------- DASHBOARD ----------
  output$total_pets <- renderUI({
    div(class = "stat-box",
        div(class = "stat-icon",
            icon("paw")
        ),
        div(class = "stat-content",
            div(nrow(pets_data()), class = "stat-number"),
            div("TOTAL PETS", class = "stat-label")
        )
    )
  })
  
  output$available_pets <- renderUI({
    div(class = "stat-box available",
        div(class = "stat-icon",
            icon("check-circle")
        ),
        div(class = "stat-content",
            div(sum(pets_data()$status == "Available"), class = "stat-number"),
            div("AVAILABLE", class = "stat-label")
        )
    )
  })
  
  output$purchased_pets <- renderUI({
    div(class = "stat-box purchased",
        div(class = "stat-icon",
            icon("shopping-cart")
        ),
        div(class = "stat-content",
            div(sum(pets_data()$status == "Purchased"), class = "stat-number"),
            div("PURCHASED", class = "stat-label")
        )
    )
  })
  
  output$pet_donut <- renderPlotly({
    req(pets_data())  # Ensure data is loaded
    
    all_types <- c("Dog", "Cat", "Bird", "Fish", "Rabbit", "Hamster")
    
    # Count available pets by type
    pet_summary <- pets_data() %>%
      filter(status == "Available") %>%
      count(type) %>%
      right_join(tibble(type = all_types), by = "type") %>%
      mutate(n = ifelse(is.na(n), 0, n))
    
    # Check if all counts are zero
    if (all(pet_summary$n == 0)) {
      # Show a single gray slice for empty state
      pet_summary <- tibble(
        type = "No pets",
        n = 1
      )
      pet_colors <- c("No pets" = "#d1d5db")  # gray
      text_info <- "none"  # can also set to "none" if you don't want text
      hover_info <- "none"  # disable hover info
      hover_template <- " 0 stock "
      show_legend <- FALSE
    } else {
      pet_colors <- c(
        "Dog" = "#FFDA4D",
        "Cat" = "#fbca43",
        "Bird" = "#f7ba3b",
        "Fish" = "#f2aa34",
        "Rabbit" = "#ec9b2f",
        "Hamster" = "#e58b2b"
      )
      text_info <- "label+percent"
      hover_template <- paste(
        "&nbsp;&nbsp;&nbsp;%{label}&nbsp;&nbsp;<br>",
        "&nbsp;&nbsp;%{value} %{customdata}&nbsp;&nbsp;<br>",
        "&nbsp;&nbsp;%{percent}&nbsp;&nbsp;"
      )
      show_legend <- TRUE
    }
    
    plot_ly(
      pet_summary,
      labels = ~type,
      values = ~n,
      type = 'pie',
      hole = 0.6,
      domain = list( 
        x = c(0, 0.8), 
        y = c(0, 1) ),
      textinfo = text_info,
      textposition = 'inside',
      textfont = list(
        family = "PSemiBold",
        size = 13,
        color = "white"
      ),
      marker = list(colors = pet_colors[pet_summary$type]),
      hovertemplate = hover_template,
      customdata = ifelse(pet_summary$n == 1, "stock", "stocks"),
      hoverlabel = list(
        font = list(
          family = "PMedium",
          size = 14,
          color = "white"
        ),
        bgcolor = "#E58B2B",
        bordercolor = "white",
        borderradius = 8
      ),
      showlegend = show_legend,
      name = "Pet Stock"
    ) %>%
      layout(
        title = list(
          text = if (all(pet_summary$n == 0)) "No pets available" else "Current Pet Stock by Type",
          font = list(
            family = "EpicPro",
            size = 22,
            color = "#E58B2B"
          ),
          x = 0.45,
          xanchor = "center"
        ),
        margin = list(t = 60),
        legend = list(
          x = 0.78,
          y = 0.5,
          xanchor = "left",
          yanchor = "middle",
          font = list(
            family = "PSemiBold",
            size = 14,
            color = "#E58B2B"
          )
        )
      )
  })
  
  
  output$pet_analysis <- renderUI({
    req(pets_data())
    
    all_types <- c("Dog", "Cat", "Bird", "Fish", "Rabbit", "Hamster")
    
    pet_summary <- pets_data() %>%
      filter(status == "Available") %>%
      count(type) %>%
      right_join(tibble(type = all_types), by = "type") %>%
      mutate(n = ifelse(is.na(n), 0, n))
    
    # Grammar helpers
    is_are <- function(n) ifelse(n == 1, "is", "are")
    pluralize <- function(n, word) ifelse(n == 1, word, paste0(word, "s"))
    format_types <- function(x) {
      if (length(x) == 0) return(NULL)
      if (length(x) == 1) return(x)
      paste(paste(x[-length(x)], collapse = ", "), "and", x[length(x)])
    }
    format_count_types <- function(df) {
      parts <- mapply(
        function(n, type) {
          paste0(n, " ", pluralize(n, "pet"), " for ", type)
        },
        df$n, df$type
      )
      format_types(parts)
    }
    
    # Stock groups
    empty_stock <- pet_summary %>% filter(n == 0) %>% pull(type)
    low_stock <- pet_summary %>% filter(n > 0 & n <= 5)
    sufficient_stock <- pet_summary %>% filter(n > 5 & n <= 20)
    high_stock <- pet_summary %>% filter(n > 20)
    
    # Create sentence containers
    ui_sentences <- list()
    
    # Empty stock
    if (length(empty_stock) > 0) {
      ui_sentences <- append(ui_sentences, list(
        div(
          style = "display:flex; align-items:center; gap:10px; margin-bottom:12px;
                 padding:12px;border:1px solid #e74c3c; border-left: 3px solid #e74c3c;border-radius:8px; background:#fdecea;color:#e74c3c; font-family: PMedium",
          tags$img(src = "icons/empty.svg", width = 24, height = 24),
          div(paste("Currently, there are no available pets for", format_types(empty_stock), "."))
        )
      ))
    }
    
    # Low stock
    if (nrow(low_stock) > 0) {
      ui_sentences <- append(ui_sentences, list(
        div(
          style = "display:flex; align-items:center; gap:10px; margin-bottom:12px;
                 padding:12px; border:1px solid #f39c12;border-left:3px solid #f39c12; border-radius:8px; background:#fff3e0;color:#f39c12;font-family:PMedium;",
          tags$img(src = "icons/low.svg", width = 24, height = 24),
          div(paste(
            "There", is_are(sum(low_stock$n)),
            format_count_types(low_stock),
            ", which", is_are(nrow(low_stock)),
            "considered low and should be restocked soon."
          ))
        )
      ))
    }
    
    # Sufficient stock
    if (nrow(sufficient_stock) > 0) {
      ui_sentences <- append(ui_sentences, list(
        div(
          style = "display:flex; align-items:center; gap:10px; margin-bottom:12px;
                 padding:12px; border:1px solid #27ae60;border-left:3px solid #27ae60; border-radius:8px; background:#eafaf1;color:#27ae60;font-family:PMedium;",
          tags$img(src = "icons/sufficient.svg", width = 24, height = 24),
          div(paste(
            "There", is_are(sum(sufficient_stock$n)),
            format_count_types(sufficient_stock),
            ", which", is_are(nrow(sufficient_stock)),
            "sufficient and do not require immediate action."
          ))
        )
      ))
    }
    
    # High stock
    if (nrow(high_stock) > 0) {
      ui_sentences <- append(ui_sentences, list(
        div(
          style = "display:flex; align-items:center; gap:10px; margin-bottom:12px;
                 padding:12px; border:1px solid #2980b9;border-left:3px solid #2980b9; border-radius:8px; background:#e8f5fd;color:#2980b9;font-family:PMedium;",
          tags$img(src = "icons/high.svg", width = 24, height = 24),
          div(paste(
            "There", is_are(sum(high_stock$n)),
            format_count_types(high_stock),
            ", which", is_are(nrow(high_stock)),
            "high; promoting them for adoption or sale is recommended."
          ))
        )
      ))
    }
    
    # Summary
    restock_types <- c(empty_stock, low_stock$type)
    maintain_types <- c(sufficient_stock$type, high_stock$type)
    
    if (length(restock_types) > 0 && length(maintain_types) > 0) {
      ui_sentences <- append(ui_sentences, list(
        div(
          style = "display:flex; align-items:center; gap:10px; margin-bottom:12px;
                 padding:12px; border:1px solid #8e44ad;border-left:3px solid #8e44ad; border-radius:8px; background:#f3e8fd;color:#8e44ad;font-family:PMedium;",
          tags$img(src = "icons/recommendation.svg", width = 24, height = 24),
          div(paste(
            "In summary, it is recommended to restock",
            format_types(restock_types),
            ", while the stock for",
            format_types(maintain_types),
            "can be maintained."
          ))
        )
      ))
    } else if (length(restock_types) > 0) {
      ui_sentences <- append(ui_sentences, list(
        div(
          style = "display:flex; align-items:center; gap:10px; margin-bottom:12px;
                 padding:12px; border:1px solid #8e44ad;border-left:3px solid #8e44ad; border-radius:8px; background:#f3e8fd;color:#8e44ad;font-family:PMedium;",
          tags$img(src = "icons/recommendation.svg", width = 24, height = 24),
          div(paste(
            "In summary, it is recommended to restock",
            format_types(restock_types),
            "."
          ))
        )
      ))
    } else if (length(maintain_types) > 0) {
      ui_sentences <- append(ui_sentences, list(
        div(
          style = "display:flex; align-items:center; gap:10px; margin-bottom:12px;
                 padding:12px; border:1px solid #8e44ad;border-left:3px solid #8e44ad; border-radius:8px; background:#f3e8fd;color:#8e44ad;font-family:PMedium;",
          tags$img(src = "icons/recommendation.svg", width = 24, height = 24),
          div(paste(
            "In summary, the stock for",
            format_types(maintain_types),
            "is sufficient and can be maintained."
          ))
        )
      ))
    }
    
    # Main container
    div(
      style = "padding:20px; background:white; display:flex; flex-direction:column; gap:10px;",
      ui_sentences
    )
  })
  
  output$notif_count_text <- renderText({
    nrow(notif_data())
  })
  
  output$notif_count_ui <- renderUI({
    count <- nrow(notif_data())  # or however you calculate notifications
    
    if(count == 0) return(NULL)  # hide completely if 0
    
    tags$span(
      count,
      class = "badge bg-danger",
      style = "
      position: absolute;
      top: 5px;
      right: 2px;
      background-color: red;
      font-size: 11px;
      width: 20px;           /* fixed width */
      height: 20px;          /* fixed height */
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 50%;     /* perfect circle */
    "
    )
  })
  
  
  output$notif_dropdown <- renderUI({
    if (!notif_visible()) return(NULL)
    
    notifs <- notif_data()
    
    # Determine border color and content
    if(nrow(notifs) == 0){
      border_color <- "#22c55e"  # green
      content <- tags$div(
        style = "
        padding: 20px;
        text-align: center;
        font-family: Poppins;
        font-size: 14px;
        color: #22c55e;
      ",
        tags$strong("All stocks are sufficient!"),
        tags$div("No low-stock pets at the moment.")
      )
    } else {
      border_color <- "#f51a01"  # red
      content <- lapply(seq_len(nrow(notifs)), function(i) {
        tags$div(
          style = "
          padding:10px;
          display:flex;
          background-color: white;
          align-items:center;
          gap:10px;
        ",
          tags$img(
            src   = petIconPath(notifs$type[i]),
            class = paste(
              "notif-icon",
              paste0("icon-", tolower(notifs$type[i]))
            )
          ),
          tags$div(
            style = "
            font-family:Poppins;
            font-size:14px;
            color:#f51a01;
            line-height:1.3;
          ",
            tags$strong(notifs$type[i]),
            tags$span(
              style = "color:#f51a01;",
              paste0(" stock low: ", notifs$available[i], " left")
            )
          )
        )
      })
    }
    
    tags$div(
      id = "notif_dropdown",
      style = paste0("
      position:absolute;
      left:280px;
      top:65px;
      white-space: nowrap;
      overflow: hidden;
      max-width:300px;
      max-height:400px;
      overflow-y:auto;
      background:white;
      border:2px solid ", border_color, ";
      border-radius:8px;
      box-shadow:0 2px 5px rgba(0,0,0,0.2);
      z-index:999;
    "),
      content
    )
  })
  
  
  observeEvent(input$close_notif_dropdown, {
    notif_visible(FALSE)
  })
  
  # ---------- PET TABLE ----------
  output$pet_table <- renderDT({
    input$reload_pets
    raw_data <- pets_data()
    db_is_empty <- nrow(raw_data) == 0
    
    if (!db_is_empty) {
    filtered_data <- pets_data() %>%
      filter(
        type %in% input$filter_type,
        gender %in% input$filter_gender,
        status %in% input$filter_status
      ) %>%
      left_join(pet_additional_infos_data(), by = c("id" = "pet_id")) %>%
      mutate(
        # ---- PET ID ----
        PetID = paste0(
          '<span style="letter-spacing:1px; font-family:PSemiBold; color:#555;">',
          "PET-",
          sprintf("%03d", id),  # zero-padded ID
          "-",
          case_when(
            type == "Dog"     ~ "DOG",
            type == "Cat"     ~ "CAT",
            type == "Bird"    ~ "BRD",
            type == "Fish"    ~ "FSH",
            type == "Rabbit"  ~ "RBT",
            type == "Hamster" ~ "HTR",
            TRUE              ~ "UNK"
          ),
          '</span>'
        ),
        
        # ---- PROFILE COLUMN ----
        PetProfile = paste0(
          '<div style="display:flex; align-items:center; gap:10px;">',
          '<img src="pet_images/', image, '" style="width:45px;height:45px;object-fit:cover;border-radius:50%;">',
          '<div style="line-height:1.2;">',
          '<div style="font-family:PSemiBold;">', name, '</div>',
          '<div style="font-size:12px;color:#555;">',
          type, ", ",
          ifelse(
            age >= 12,
            paste0(floor(age / 12), " yr",
                   ifelse(age %% 12 > 0, paste0(" ", age %% 12, " mo"), "")
            ),
            paste0(age, " mo")
          ),
          '</div></div></div>'
        ),
        
        # ---- SORT HELPERS ----
        PetName = name,
        
        # ---- FIX TIMEZONE (UTC → PH) ----
        AddedOn_raw = as.POSIXct(created_at, tz = "UTC") %>%
          as.POSIXct(tz = "Asia/Manila"),
        
        AddedOn = paste0(
          format(as.POSIXct(created_at, tz = "UTC") %>% as.POSIXct(tz = "Asia/Manila"), "%b %d, %Y"),
          "<br>",
          format(as.POSIXct(created_at, tz = "UTC") %>% as.POSIXct(tz = "Asia/Manila"), "%I:%M %p")
        ),
        
        Breed = ifelse(is.na(breed), "N/A", breed),
        
        Status = ifelse(
          status == "Available",
          '<span style="display:inline-block;padding:5px 12px;border-radius:15px;background:#28a745;color:white;font-size:12px;">Available</span>',
          '<span style="display:inline-block;padding:5px 12px;border-radius:15px;background:#ffc107;color:white;font-size:12px;">Purchased</span>'
        ),
        
        Actions = paste0(
          '<div style="display:flex; gap:8px; justify-content:center;">',
          
          '<button class="btn-icon btn-update" ',
          'title="Edit" ',
          'onclick="Shiny.setInputValue(\'edit_id\', ', id, ', {priority:\'event\'})">',
          '<img src="icons/edit2.svg" width="16" height="16">',
          '</button>',
          
          '<button class="btn-icon btn-delete" ',
          'title="Delete" ',
          'onclick="Shiny.setInputValue(\'delete_id\', ', id, ', {priority:\'event\'})">',
          '<img src="icons/delete.svg" width="18" height="18">',
          '</button>',
          
          '</div>'
        )
      ) %>%
      select(
        PetID,       # <-- added Pet ID column
        PetProfile,
        PetName,
        Breed,
        gender,
        price,
        Status,
        AddedOn,
        AddedOn_raw,
        Actions
      )   } else {
        # 👇 Only here we force empty table
        filtered_data <- data.frame(
          PetID = character(),
          PetProfile = character(),
          PetName = character(),
          Breed = character(),
          gender = character(),
          price = numeric(),
          Status = character(),
          AddedOn = character(),
          AddedOn_raw = as.POSIXct(character()),
          Actions = character(),
          stringsAsFactors = FALSE
        )
      }
    filtered_empty <- !db_is_empty && nrow(filtered_data) == 0
    
    datatable(
      filtered_data,
      escape = FALSE,
      rownames = FALSE,
      selection = "none",
      colnames = c(
        "Pet ID",    # <-- display Pet ID
        "Profile",
        "PetName",
        "Breed",
        "Gender",
        "Price ($)",
        "Status",
        "Added On",
        "AddedOn_raw",
        "Actions"
      ),
      options = list(
        columnDefs = list(
          list(visible = FALSE, targets = c(2, 8)),          # hide AddedOn_raw only
          list(orderable = TRUE, targets = 1, orderData = 2), # Profile → PetName
          list(orderable = TRUE, targets = 7, orderData = 8), # Added On → raw datetime
          list(orderable = FALSE, targets = 9),
          list(className = "dt-center", targets = 9)
        ),
        order = list(list(8, "desc")),  # newest first
        language = list(
          zeroRecords = HTML(
            " <div style='width:100vw; margin-left:calc(-50vw + 50%); padding:30px; text-align:center; background-color:white;'> 
        <img src='corgisleeping2.gif' style='margin-bottom:0rem; width:auto; height:14rem;'> 
        <p style='font-size:2.5rem; font-family:PExBold; color:#374151; margin-bottom:0.2rem; text-align:center;'>No pets match your search</p> 
        <p style='font-size:1.3rem; font-family:PMedium; color:#6b7280; margin-bottom:1rem; text-align:center;'>It looks like your search or filter didn’t match any existing pets</p> 
        <button onclick='Shiny.setInputValue(\"reload_pets\", Math.random(), {priority:\"event\"})' style='font-family:PSemiBold; display:inline-flex; align-items:center; background: linear-gradient(to right, #fcd34d, #f97316); color:white; padding:0.5rem 1.5rem; border-radius:9999px; box-shadow:0 2px 4px rgba(0,0,0,0.15); transition:all 0.3s ease; gap:0.5rem; border:none; cursor:pointer; font-size:1.5rem;'> 
          <img src='icons/reload2.svg' width='16' height='16'> Reload 
      </div> "
          ),
          emptyTable = HTML(
            if (filtered_empty) {
              "
      <div style='width:100vw; margin-left:calc(-50vw + 50%); padding:30px; text-align:center; background-color:white;'> 
        <img src='corgisleeping2.gif' style='margin-bottom:0rem; width:auto; height:14rem;'> 
        <p style='font-size:2.5rem; font-family:PExBold; color:#374151; margin-bottom:0.2rem; text-align:center;'>No pets match your search</p> 
        <p style='font-size:1.3rem; font-family:PMedium; color:#6b7280; margin-bottom:1rem; text-align:center;'>It looks like your search or filter didn’t match any existing pets</p> 
        <button onclick='Shiny.setInputValue(\"reload_pets\", Math.random(), {priority:\"event\"})' style='font-family:PSemiBold; display:inline-flex; align-items:center; background: linear-gradient(to right, #fcd34d, #f97316); color:white; padding:0.5rem 1.5rem; border-radius:9999px; box-shadow:0 2px 4px rgba(0,0,0,0.15); transition:all 0.3s ease; gap:0.5rem; border:none; cursor:pointer; font-size:1.5rem;'> 
          <img src='icons/reload2.svg' width='16' height='16'> Reload 
      </div>
      "
            } else {
              "
      <div style='width:100vw; margin-left:calc(-50vw + 50%); padding:30px; text-align:center; background-color:white;'> 
        <img src='corgibox2.gif' style='margin-bottom:0rem; width:auto; height:14rem;'> 
        <p style='font-size:2.5rem; font-family:PExBold; color:#374151; margin-bottom:0.2rem; text-align:center;'>No pets in inventory</p> 
        <p style='font-size:1.3rem; font-family:PMedium; color:#6b7280; margin-bottom:1rem; text-align:center;'>No pets are currently in the inventory—add one to begin management.</p> 
        <button onclick='Shiny.setInputValue(\"open_add\", Math.random(), {priority:\"event\"})' style='font-family:PSemiBold; display:inline-flex; align-items:center; background: linear-gradient(to right, #fcd34d, #f97316); color:white; padding:0.5rem 1.5rem; border-radius:9999px; box-shadow:0 2px 4px rgba(0,0,0,0.15); transition:all 0.3s ease; gap:0.5rem; border:none; cursor:pointer; font-size:1.5rem;'> 
          <img src='icons/addicon.svg' width='16' height='16'> Add Pet 
      </div>
      "
            }
          )
        )
      )
    )
  })
  
  notif_data <- reactiveVal(
    tibble(
      type = character(),
      available = numeric()
    )
  )
  is_editing <- reactiveVal(FALSE)
  notif_visible <- reactiveVal(FALSE)
  original_image <- reactiveVal(NULL)
  current_edit_id <- reactiveVal(NULL)
  # Temporary storage
  temp_image <- reactiveVal(NULL)
  cropped_image <- reactiveVal(NULL)
  
  USERNAME <- "admin"
  PASSWORD <- "petopia123"
  
  # Login state
  logged_in <- reactiveVal(NULL)
  js_ready <- reactiveVal(FALSE)

  # Reactive values to store form inputs temporarily
  pet_form <- reactiveValues(
    name = NULL,
    type = NULL,
    age = NULL,
    gender = NULL,
    price = NULL,
    status = NULL,
    breed = NULL
  )
  
  login_ui <- div(
    style = "
    height: 100vh;       /* full viewport height */
    width: 100vw;        /* full viewport width */
    margin: 0;
    padding: 0;
    position: relative;  /* for absolutely positioned images */
    display: flex;
    justify-content: center;
    align-items: center;
    background: linear-gradient(270deg, #FFEB3B, #FFC629, #FFEB3B, #FFC629, #FFEB3B);
    background-size: 600% 600%;
    animation: gradientMove 18s ease infinite;
  ",
    
    tags$style(HTML("
    @keyframes gradientMove {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 50%; }
      100% { background-position: 0% 50%; }
    }
  ")),
  
    # Top-left image
    tags$img(
      src = "doghead.png",
      style = "
      position: absolute;
      top: 0;
      left: 0;
      width: 550px;    /* adjust as needed */
      height: auto;
      z-index: 1;
    "
    ),
    
    # Bottom-right image
    tags$img(
      src = "dogtail.png",
      style = "
      position: absolute;
      bottom: 0;
      right: 0;
      width: 550px;    /* adjust as needed */
      height: auto;
      z-index: 1;
    "
    ),
    
    # Login box container
    div(
      style = "
      display: flex;
      width: 700px;             /* total width of login box */
      border-radius: 30px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.2);
      z-index: 2;               /* above the corner images */
    ",
      
      # Left side: image
      div(
        style = "
    width: 50%;
    border-radius: 30px 0 0 15px;
    background-color: #E58B2B;

    display: flex;
    justify-content: center;   /* horizontal center */
    align-items: center;       /* vertical center */
    gap: 5px;   
  ",
        
        tags$img(
          src = "logo.png",
          id = "animated_logo",
          style = "
          height: 60px;
  "
        ),
        
        tags$img(
          src = "logotitle.png",
          style = "
      width: auto;
      height: 60px;
    "
        )
      ),
      
      # Right side: login form
      div(
        style = "
    width: 50%;
    background-color: white;
    padding: 30px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    text-align: left;
    position: relative;   /* needed for absolute child positioning */
  ",
        
        tags$img(
          src = "storeceiling.png",
          style = "
      position: absolute;
      top: -70px;          /* adjust how far above the box */
      left: 50%;           /* center horizontally */
      transform: translateX(-50%);
      width: 360px;        /* adjust size */
      height: auto;
      z-index: 3;          /* above the box */
    "
        ),
        tags$h2(
          "Welcome back, ",
          tags$span("Admin !", class = "login-username"),
          class = "login-title"
        ),
        textInput("login_user", "Username", placeholder = "Enter your username"),
        div(
          class = "password-wrapper",
          
          tags$label(
            "Password",
            `for` = "login_pass"   # must match input id
          ),
          
          tags$input(
            id = "login_pass",
            type = "password",
            placeholder = "Enter your password",
            class = "form-control"
          ),
          
          tags$img(
            id = "toggle_pass",
            src = "icons/eye-slash.svg",
            class = "eye-icon"
          )
        ),
        actionButton("login_btn", "Login", class = "btn btn-warning")
      )
    ),

  )
  

  
  
  main_ui <- tagList(  
    div(
      style = "padding-left: 15px;padding-right: 15px;padding-bottom: 15px;",
    div(
      style = "position: relative; width: 100%; text-align: center;",
      
      tags$h1(
        "", 
        id = "app_title",
        style = "
      display: inline-block; 
      position: relative; 
      padding: 40px 0;       /* keep your padding */
      font-size: 36px;
      color: white;
      z-index: 900;         /* above curtains */
    "
      ),
      
      # Center image
      tags$img(
        src = "petopia.png",
        style = "
      position: absolute;
      top: 0; 
      left: 50%; 
      transform: translateX(-50%);
      height: 100%;      /* full header height including padding */
      z-index: 1000;
      pointer-events: none;
    "
      ),
      
      # Left curtain
      tags$img(
        src = "curtain.png",
        style = "
      position: absolute;
      height: 130px; 
      top: 20px;          /* match top padding of h1 */
      bottom: 40px;       /* match bottom padding of h1 */
      left: 0;
      z-index: 900;
      pointer-events: none;
    "
      ),
      
      # Right curtain
      tags$img(
        src = "curtain.png",
        style = "
      position: absolute;
      height: 130px; 
      top: 20px;          /* match top padding of h1 */
      bottom: 40px;       /* match bottom padding of h1 */
      right: 0;
      transform: scaleX(-1); 
      z-index: 900;
      pointer-events: none;
    "
      )
    ),
    
    tags$img(
      src = "catplaying.gif",
      style = "
    position: absolute;
    top:97px;       /* adjust as needed */
    right: 15px;
    width: 200px;
    z-index: 1000;
    pointer-events: none;
  "
    ),
    
    actionButton(
      "logout_btn", "Logout", icon = icon("sign-out-alt"),
      style = "
    position: absolute;
    top: 165px;              /* same vertical position as the GIF */
    left: 305px;           /* adjust: GIF width + some spacing */
    z-index: 1001;          /* above background but below the GIF if needed */
    padding: 5px 12px;
    background-color: #F46A6A;
    color: white;
    font-family: EpicPro;
    letter-spacing: 1px;
    border: none;
    cursor: pointer;
  "
    ),
    
    tabsetPanel(
      id = "tabs",
      
      # ---------- DASHBOARD TAB ----------
      tabPanel(
        title = tagList(
          icon("tachometer-alt"),
          span("DASHBOARD")
        ),
        fluidRow(
          column(4, uiOutput("total_pets")),
          column(4, uiOutput("available_pets")),
          column(4, uiOutput("purchased_pets"))
        ),
        hr(),
        fluidRow(
          column(
            6,
            plotlyOutput("pet_donut")   # Donut chart here
          ),
          column(
            6,
            uiOutput("pet_analysis")    # Description/analysis here
          )
        )
      ),
      
      # ---------- PETS TAB ----------
      tabPanel(
        title = tagList(
          icon("paw"),
          span("PETS")
        ),
        fluidRow(
          style = "margin-top: 5px;",
          
          # --- Left Sidebar ---
          column(
            width = 3,
            wellPanel(
              class = "sidebar-panel",
              
              div(
                style = "display:flex; align-items:center; gap:10px;",
                
                actionButton(
                  "open_add",
                  "Add Pet",
                  icon = icon("plus"),
                  class = "btn-add"
                ),

                
                actionButton(
                  "reset_filter",
                  label = NULL,
                  icon = tags$img(
                    src = "icons/resetfilter.svg",
                    width = "25px",
                    height = "25px"
                  ),
                  style = "
                  border-radius:10px;
                  background: linear-gradient(to right, #FFC629, #FFD700);
                  border:2px solid white;
                  cursor:pointer;
                  padding: 3px 5px;
                "
                ),
                
                div(
                  style = "position:relative;",
                  
                  actionButton(
                    "notif_icon",
                    label = NULL,
                    icon = tags$img(
                      src = "icons/lowstock.svg",
                      width = "45px",
                      height = "45px"
                    ),
                    style = "
                    border-radius:50%;
                    background:transparent;
                    border:none;
                    margin-left: 30px;
                  "
                  ),
                  
                  uiOutput("notif_count_ui")
                )
              )
              ,
              
              uiOutput("notif_dropdown"),
              hr(),
              
              h4(tagList(icon("filter"), span("FILTER BY TYPE"))),
              checkboxGroupInput(
                "filter_type", NULL,
                choices = c("Dog", "Cat", "Bird", "Fish", "Rabbit", "Hamster"),
                selected = c("Dog", "Cat", "Bird", "Fish", "Rabbit", "Hamster")
              ),
              
              h4(tagList(icon("filter"), span("FILTER BY GENDER"))),
              checkboxGroupInput(
                "filter_gender", NULL,
                choices = c("Male", "Female"),
                selected = c("Male", "Female")
              ),
              
              h4(tagList(icon("filter"), span("FILTER BY STATUS"))),
              checkboxGroupInput(
                "filter_status", NULL,
                choices = c("Available", "Purchased"),
                selected = c("Available", "Purchased")
              )
            )
          ),
          
          # --- Table on Right ---
          column(
            width = 9,
            DTOutput("pet_table")
          )
        )
      )
    )
  )
  )
  # 1️⃣ JS: check localStorage BEFORE Shiny renders
  shinyjs::runjs("
  var loggedIn = localStorage.getItem('logged_in');
  Shiny.setInputValue('stored_login', loggedIn === 'true', {priority: 'event'});
")
  
  # 2️⃣ Reactively restore login
  observeEvent(input$stored_login, {
    logged_in(input$stored_login)
    js_ready(TRUE)  # now we know login state
  })
  
  # 3️⃣ Render UI only after we know login state
  output$page <- renderUI({
    req(js_ready())  # wait until JS has reported login state
    if (logged_in()) main_ui else login_ui
  })
  
  # Login button
  observeEvent(input$login_btn, {
    
    # Trim whitespace
    login_user <- trimws(input$login_user)
    login_pass <- trimws(input$login_pass)
    
    if (login_user == USERNAME && login_pass == PASSWORD) {
      
      logged_in(TRUE)
      shinyjs::runjs("localStorage.setItem('logged_in', 'true');")
      
      showNotification(
        HTML(
          paste0(
            '<div style="display:flex; align-items:center; gap:7px;">',
            '<img src="icons/check.svg" style="width:17px;height:17px;">',
            '<span style="flex:1; font-family:PSemiBold;">Login successful!</span>',
            '<button onclick="$(this).closest(\'.shiny-notification\').remove()" ',
            'style="background:none;border:none;cursor:pointer;margin-bottom:2px;">',
            '<img src="icons/close.svg" style="width:12px;height:12px;">',
            '</button>',
            '</div>'
          )
        ),
        type = "message"
      )
      
    } else {
      
      showNotification(
        HTML(
          paste0(
            '<div style="display:flex; align-items:center; gap:7px;">',
            '<img src="icons/error.svg" style="width:17px;height:17px;">',
            '<span style="flex:1; font-family:PSemiBold;">Invalid username or password!</span>',
            '<button onclick="$(this).closest(\'.shiny-notification\').remove()" ',
            'style="background:none;border:none;cursor:pointer;margin-bottom:2px;">',
            '<img src="icons/close.svg" style="width:12px;height:12px;">',
            '</button>',
            '</div>'
          )
        ),
        type = "error"
      )
      
    }
  })
  
  observeEvent(input$logout_btn, {
    
    showModal(      
      tags$div(
      id = "modal3",
      modalDialog(
      title = "Confirm Logout",
      "Are you sure you want to log out?",
      easyClose = TRUE,      # allows clicking outside to close
      footer = tagList(
        modalButton("Cancel"),  # just closes the modal
        actionButton("confirm_logout", "Logout", class = "btn-delete2")
      )
    )))
  })
  # 5️⃣ Logout button
  observeEvent(input$confirm_logout, {
    removeModal()  # close the modal
    logged_in(FALSE)
    shinyjs::runjs("localStorage.removeItem('logged_in');")
  })
  
  # ---------- ADD PET MODAL ----------
  showAddPetModal <- function(cropped = NULL) {
    
    required_class <- if (is_editing()) NULL else "required-field"
    
    showModal(
      tags$div(
        id = "modal1",
        modalDialog(
          title = tags$div(
            style = "display:flex; align-items:center; gap:8px;",
            
            tags$img(
              src = if (is_editing())
                "icons/edit.svg"
              else
                "icons/add.svg",
              height = "30px",
              width = "30px",
              style = "vertical-align:middle;"
            ),
            
            span(
              if (is_editing()) "Update Pet" else "Add Pet"
            )
          ),
          
          # ---- Modal body ----
          div(
            class = "modal-body-content",
            style = "display: flex; flex-wrap: wrap; column-gap: 70px; justify-content: center; padding: 10px 0;",
            
            # Pet Name
            div(
              class = required_class,
              style = "flex: 1 1 48%; max-width: 250px;",
              textInput(
                "m_name",
                "Pet Name",
                value = pet_form$name,
                placeholder = "Enter pet name"
              )
            ),
            
            # Pet Type
            div(
              class = required_class,
              style = "flex: 1 1 48%; max-width: 250px;",
              selectInput(
                "m_type",
                "Pet Type",
                choices = list(
                  "Select pet type" = "",
                  "Dog" = "Dog",
                  "Cat" = "Cat",
                  "Bird" = "Bird",
                  "Fish" = "Fish",
                  "Rabbit" = "Rabbit",
                  "Hamster" = "Hamster"
                ),
                selected = if (is.null(pet_form$type)) "" else pet_form$type
              )
            ),
            
            # Age
            div(
              class = required_class,
              style = "flex: 1 1 48%; max-width: 250px;",
              numericInput(
                "m_age",
                "Age (months)",
                value = pet_form$age,
                min = 0
              )
            ),
            
            # Gender
            div(
              class = required_class,
              style = "flex: 1 1 48%; max-width: 250px;",
              selectInput(
                "m_gender",
                "Gender",
                choices = list(
                  "Select gender" = "",
                  "Male" = "Male",
                  "Female" = "Female"
                ),
                selected = if (is.null(pet_form$gender)) "" else pet_form$gender
              )
            ),
            
            # Price
            div(
              class = required_class,
              style = "flex: 1 1 48%; max-width: 250px;",
              numericInput(
                "m_price",
                "Price",
                value = pet_form$price,
                min = 0
              )
            ),
            
            # Status
            div(
              class = required_class,
              style = "flex: 1 1 48%; max-width: 250px;",
              selectInput(
                "m_status",
                "Status",
                choices = c("Available", "Purchased"),
                selected = if (is.null(pet_form$status)) "Available" else pet_form$status
              )
            ),
            
            # Breed
            div(
              style = "flex: 1 1 48%; max-width: 250px;",
              textInput(
                "m_breed",
                "Breed (optional)",
                value = pet_form$breed,
                placeholder = "Enter breed (optional)"
              )
            ),
            
            # Image Upload
            div(
              class = required_class,
              style = "flex: 1 1 48%; max-width: 250px; display:flex; flex-direction:column; gap:2px;",
              
              tags$style(HTML("
              #m_image + .shiny-input-container {
                margin-top: 0px !important;
                margin-bottom: 0px !important;
              }
            ")),
              
              fileInput(
                "m_image",
                label = if (
                  is.null(cropped_image()) && is.null(temp_image())
                ) "Upload Pet Image" else "Upload New Pet Image",
                accept = c(".png", ".jpg", ".jpeg")
              ),
              
              if (!is.null(cropped_image()) || !is.null(temp_image())) {
                tags$img(
                  src = if (!is.null(cropped_image()))
                    cropped_image()
                  else
                    temp_image(),
                  style = "max-width:100px; border-radius:10px; margin-top:-40px;"
                )
              }
            )
          ),
          
          # ---- Modal footer ----
          footer = tagList(
            modalButton("Cancel"),
            actionButton(
              "save_pet",
              label = tagList(
                tags$img(src = "icons/save.svg", width = "16px", height = "16px", style = "vertical-align:middle; margin-right:3px; margin-bottom: 2px;"),
                if (is_editing()) "Update" else "Save"
              ),
              class = "btn-add",
              style = "background: linear-gradient(to right, #fcd34d, #f97316);color:white;border:none;padding:6px 12px;display:inline-flex;align-items:center;gap:3px;"
            )
          ),
          
          size = "l",
          class = "custom-add-pet-modal"
        )
      )
    )
  }

observeEvent(input$notif_icon, { notif_visible(!notif_visible()) })
  
observeEvent(input$reset_filter, {
  updateCheckboxGroupInput(session, "filter_type",
                           selected = c("Dog", "Cat", "Bird", "Fish", "Rabbit", "Hamster"))
  updateCheckboxGroupInput(session, "filter_gender",
                           selected = c("Male", "Female"))
  updateCheckboxGroupInput(session, "filter_status",
                           selected = c("Available", "Purchased"))
})

  
observe({
  req(pets_data())
  
  all_types <- tibble(type = c("Dog", "Cat", "Bird", "Fish", "Rabbit", "Hamster"))
  
  stock_count <- pets_data() %>%
    filter(status == "Available") %>%
    count(type) %>%
    right_join(all_types, by = "type") %>%
    mutate(n = ifelse(is.na(n), 0, n))
  
  # Only keep types with 5 or fewer pets
  low_stock <- stock_count %>% filter(n <= 5)
  
  # Update notif_data reactiveVal
  notif_data(low_stock %>% select(type, available = n))
})

  
  
  # ---------- OPEN ADD PET ----------
  observeEvent(input$open_add, {
    
    is_editing(FALSE)
    current_edit_id(NULL)
    
    pet_form <<- reactiveValues()
    temp_image(NULL)
    cropped_image(NULL)
    
    showAddPetModal()
  })
  
  
  # ---------- PREVIEW / CROP MODAL ----------
  observeEvent(input$m_image, {
    req(input$m_image)
    
    # Save uploaded image as base64
    img_file <- input$m_image$datapath
    img_type <- tools::file_ext(input$m_image$name)
    img_base64 <- base64enc::dataURI(file = img_file, mime = paste0("image/", img_type))
    
    temp_image(img_base64)
    
    showModal(
      tags$div(
        id = "modal2",
        modalDialog(
          title = "Preview & Crop Image",
          div(
            id = "cropper_container",
            style = "width:100% !important; height: 60vh !important; display:block; padding:0; margin:0;",
            tags$img(
              id = "cropper_preview",
              src = img_base64,
              style = "width:100% !important; height: 100% !important; display:block; object-fit:contain;"
            )
          ),
          footer = tagList(
            actionButton("discard_crop", "Discard", class = "btn btn-secondary"),
            actionButton(
              "confirm_crop",
              label = tagList(
                tags$img(
                  src = "icons/upload.svg",
                  width = "16px",
                  height = "16px",
                  style = "vertical-align:middle; margin-right:3px; margin-bottom: 2px;"
                ),
                "Upload"  # fixed label
              ),
              class = "btn-add",
              style = "background: linear-gradient(to right, #fcd34d, #f97316);
           color:white; border:none; padding:6px 12px;
           display:inline-flex; align-items:center; gap:3px;"
            )
          ),
          size = "l",      # large modal for more width
          easyClose = FALSE
        )
      )
    )
    
    # Send to Cropper.js
    session$sendCustomMessage("showImage", list(src = img_base64))
  })
  
  # ---------- CONFIRM CROPPING ----------
  observeEvent(input$cropped_image, {
    req(input$cropped_image)
    cropped_image(input$cropped_image)
    
    removeModal() 
    
    # Keep previous inputs
    pet_form$name <- input$m_name
    pet_form$type <- input$m_type
    pet_form$age <- input$m_age
    pet_form$gender <- input$m_gender
    pet_form$price <- input$m_price
    pet_form$status <- input$m_status
    pet_form$breed <- input$m_breed
    
    showAddPetModal(cropped = cropped_image())
  })
  
  observeEvent(input$discard_crop, {
    # Save current inputs before closing crop modal
    isolate({
      pet_form$name   <- input$m_name
      pet_form$type   <- input$m_type
      pet_form$age    <- input$m_age
      pet_form$gender <- input$m_gender
      pet_form$price  <- input$m_price
      pet_form$status <- input$m_status
      pet_form$breed  <- input$m_breed
    })
    
    removeModal()  # Close the crop modal
    
    if (!is_editing()) {
      # Adding new pet → discard everything
      temp_image(NULL)
      cropped_image(NULL)
      reset("m_image")
    } else {
      # Editing → restore the original image before browsing
      temp_image(original_image())
      cropped_image(NULL)
    }
    
    # Reopen Add Pet modal
    showAddPetModal(cropped = NULL)
  })
  
  observeEvent(input$reload_pets, {
    loadPets()
    loadPetAdditionalInfos()
  })
  
  # ---------- EDIT PET ----------
  observeEvent(input$edit_id, {
    req(input$edit_id)
    
    pet <- pets_data() %>% filter(id == input$edit_id)
    pet_info <- pet_additional_infos_data() %>% filter(pet_id == input$edit_id)
    
    pet_form$name   <- pet$name
    pet_form$type   <- pet$type
    pet_form$age    <- pet$age
    pet_form$gender <- pet$gender
    pet_form$price  <- pet$price
    pet_form$status <- pet$status
    pet_form$breed  <- pet_info$breed
    
    temp_image(paste0("pet_images/", pet_info$image))
    original_image(paste0("pet_images/", pet_info$image))
    cropped_image(NULL)
    
    is_editing(TRUE)
    current_edit_id(input$edit_id)
    
    showAddPetModal()
  })
  
  # ---------- SAVE PET ----------
  observeEvent(input$save_pet, {
    
    # Initialize validity flag
    valid <- TRUE
    
    # ---------- VALIDATION ----------
    if (is.null(input$m_name) || input$m_name == "") {
      feedbackWarning("m_name", text = "This field is required", color = "red", show = TRUE)
      valid <- FALSE
    } else hideFeedback("m_name")
    
    if (is.null(input$m_type) || input$m_type == "") {
      feedbackWarning("m_type", text = "This field is required", color = "red", show = TRUE)
      valid <- FALSE
    } else hideFeedback("m_type")
    
    if (is.null(input$m_age) || is.na(input$m_age) || input$m_age <= 0) {
      feedbackWarning("m_age", text = "This field is required", color = "red", show = TRUE)
      valid <- FALSE
    } else hideFeedback("m_age")
    
    if (is.null(input$m_gender) || input$m_gender == "") {
      feedbackWarning("m_gender", text = "This field is required", color = "red", show = TRUE)
      valid <- FALSE
    } else hideFeedback("m_gender")
    
    if (is.null(input$m_price) || is.na(input$m_price) || input$m_price < 0) {
      feedbackWarning("m_price", text = "This field is required", color = "red", show = TRUE)
      valid <- FALSE
    } else hideFeedback("m_price")
    
    if (is.null(input$m_status) || input$m_status == "") {
      feedbackWarning("m_status", text = "This field is required", color = "red", show = TRUE)
      valid <- FALSE
    } else hideFeedback("m_status")
    
    if (!is_editing() && !isTruthy(cropped_image()) && !isTruthy(temp_image())) {
      feedbackWarning("m_image", text = "Pet image is required", color = "red", show = TRUE)
      valid <- FALSE
    } else hideFeedback("m_image")
    
    if (!valid) return()
    
    # ---------- HANDLE IMAGE ----------
    img_filename <- NULL
    image_changed <- FALSE
    
    if (!is.null(cropped_image()) && grepl("^data:image", cropped_image())) {
      # New cropped image uploaded
      base64data <- gsub("^data:image/[^;]+;base64,", "", cropped_image())
      img_bin <- base64enc::base64decode(base64data)
      
      dir.create("www/pet_images", showWarnings = FALSE, recursive = TRUE)
      
      img_filename <- paste0(gsub("[- :]", "", Sys.time()), "_", input$m_name, ".png")
      writeBin(img_bin, file.path("www/pet_images", img_filename))
      
      image_changed <- TRUE
    } else if (is_editing()) {
      # Keep existing filename from DB
      pet_info <- pet_additional_infos_data() %>% filter(pet_id == current_edit_id())
      if (nrow(pet_info) > 0) {
        img_filename <- pet_info$image
      }
    }
    
    # ---------- HANDLE BREED ----------
    breed_value <- if (!is.null(input$m_breed) && nzchar(trimws(input$m_breed))) {
      input$m_breed
    } else {
      "N/A"
    }
    
    # ---------- SAVE TO DATABASE ----------
    if (is_editing()) {
      
      dbBegin(db)
      tryCatch({
        
        # Update pets table
        dbExecute(db,
                  "UPDATE pets 
               SET name=?, type=?, age=?, gender=?, price=?, status=? 
               WHERE id=?",
                  params = list(
                    input$m_name, input$m_type, input$m_age,
                    input$m_gender, input$m_price, input$m_status,
                    current_edit_id()
                  )
        )
        
        # Update pet_additional_infos table
        if (image_changed) {
          # Update breed and image
          dbExecute(db,
                    "UPDATE pet_additional_infos
             SET breed=?, image=?
             WHERE pet_id=?",
                    params = list(breed_value, img_filename, current_edit_id())
          )
        } else {
          # Update only breed
          dbExecute(db,
                    "UPDATE pet_additional_infos
             SET breed=?
             WHERE pet_id=?",
                    params = list(breed_value, current_edit_id())
          )
        }
        
        dbCommit(db)
        showNotification(
          HTML(
            paste0(
              '<div style="display:flex; align-items:center; gap:7px;">',
              '<img src="icons/check.svg" style="width:17px;height:17px;">',
              '<span style="flex:1; font-family:PSemiBold;">Pet updated successfully!</span>',
              '<button onclick="$(this).closest(\'.shiny-notification\').remove()" ',
              'style="background:none;border:none;cursor:pointer;margin-bottom:2px;">',
              '<img src="icons/close.svg" style="width:12px;height:12px;">',
              '</button>',
              '</div>'
            )
          ),
          type = "message"
        )
        
      }, error = function(e){
        dbRollback(db)
        showNotification(paste("Error updating pet:", e$message), type = "error")
        return()
      })
      
    } else {
      
      dbBegin(db)
      tryCatch({
        
        # Insert into pets table
        dbExecute(db,
                  "INSERT INTO pets (name, type, age, gender, price, status)
                 VALUES (?, ?, ?, ?, ?, ?)",
                  params = list(
                    input$m_name, input$m_type, input$m_age,
                    input$m_gender, input$m_price, input$m_status
                  )
        )
        
        pet_id <- dbGetQuery(db, "SELECT last_insert_rowid() AS id")$id[1]
        
        # Insert into additional infos table
        dbExecute(db,
                  "INSERT INTO pet_additional_infos (pet_id, breed, image, created_at)
                  VALUES (?, ?, ?, datetime('now'))",
                  params = list(pet_id, breed_value, img_filename)
        )
        
        dbCommit(db)
        showNotification(
          HTML(
            paste0(
              '<div style="display:flex; align-items:center; gap:7px;">',
              '<img src="icons/check.svg" style="width:17px;height:17px;">',
              '<span style="flex:1; font-family:PSemiBold;">Pet added successfully!</span>',
              '<button onclick="$(this).closest(\'.shiny-notification\').remove()" ',
              'style="background:none;border:none;cursor:pointer;margin-bottom:2px;">',
              '<img src="icons/close.svg" style="width:12px;height:12px;">',
              '</button>',
              '</div>'
            )
          ),
          type = "message"
        )
        
      }, error = function(e){
        dbRollback(db)
        showNotification(paste("Error adding pet:", e$message), type = "error")
        return()
      })
      
    }
    
    # ---------- REFRESH DATA ----------
    loadPets()
    loadPetAdditionalInfos()
    
    # ---------- RESET STATE ----------
    is_editing(FALSE)
    current_edit_id(NULL)
    temp_image(NULL)
    cropped_image(NULL)
    
    pet_form$name   <- NULL
    pet_form$type   <- NULL
    pet_form$age    <- NULL
    pet_form$gender <- NULL
    pet_form$price  <- NULL
    pet_form$status <- NULL
    pet_form$breed  <- NULL
    
    removeModal()
    
  })
  
  
  
  
  # ---------- DELETE PET ----------
  observeEvent(input$delete_id, {
    req(input$delete_id)
    showModal(      
      tags$div(
      id = "modal3",
      modalDialog(
      title = "Confirm Delete",
      "Are you sure you want to delete this pet?",
      easyClose = TRUE,
      footer = tagList(
        modalButton("Cancel"),
        actionButton(
          "confirm_delete",
          label = tagList(
            tags$img(
              src = "icons/delete.svg",
              width = "16px",
              height = "16px",
              style = "vertical-align:middle; margin-right:3px; margin-bottom: 3px;"
            ),
            "Delete"  # fixed label
          ),
          class = "btn-delete2"
        )
      )
    ))
    )
  })
  
  
  observeEvent(input$confirm_delete, {
    req(input$delete_id)
    
    tryCatch({
      # Delete the additional info row first
      dbExecute(db, "DELETE FROM pet_additional_infos WHERE pet_id = ?", params = list(input$delete_id))
      
      # Delete the pet
      dbExecute(db, "DELETE FROM pets WHERE id = ?", params = list(input$delete_id))
      
      removeModal()
      
      # Refresh data
      loadPets()
      loadPetAdditionalInfos()
      
      showNotification(
        HTML(
          paste0(
            '<div style="display:flex; align-items:center; gap:7px;">',
            '<img src="icons/check.svg" style="width:17px;height:17px;">',
            '<span style="flex:1; font-family:PSemiBold;">Pet deleted successfully!</span>',
            '<button onclick="$(this).closest(\'.shiny-notification\').remove()" ',
            'style="background:none;border:none;cursor:pointer;margin-bottom:2px;">',
            '<img src="icons/close.svg" style="width:12px;height:12px;">',
            '</button>',
            '</div>'
          )
        ),
        type = "message"
      )
      
    }, error = function(e) {
      showNotification(paste("Error deleting pet:", e$message), type = "error")
    })
  })
}

shinyApp(ui, server)