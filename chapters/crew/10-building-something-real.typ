= Building Something Real

#figure(
  image("../../assets/illustrations/crew/ch10-building-real.jpg", width: 80%),
  caption: [_From idea to working prototype in a weekend._],
)

This is the chapter where everything comes together. We're going to walk through building an actual application — from idea to working product — using an agent. No code. No programming experience. Just clear thinking, good instructions, and everything you've learned so far.

The app is real. The industry is real. The process is exactly what it looks like when someone who knows their domain sits down with an agent and builds something.

== The Idea

Your uncle installs windows for a living. Not the Microsoft kind — the glass kind. Good business, steady work. He's been doing it for fifteen years and knows every window model, every frame type, every trick for getting a perfect seal in a crooked old house.

But his quoting process is stuck in 2005. He measures the wall, picks a window from a paper catalogue, calculates the price on a calculator, types it all into a Word document, saves it as a PDF, and emails it to the customer. Half the time, the customer can't picture what the window will actually look like in their wall. The other half, they lose the PDF and call back asking for another one.

You're going to build him something better. An app where he enters the measurements, picks a window model, sees a 3D preview of what it'll look like, and generates a professional quote — all in one place, accessible from his tablet at the job site.

You're going to build it this weekend.

== Before You Touch the Agent

The biggest mistake people make is opening the agent and immediately typing "build me a window quoting app." That's Captain Alex. We're going to be Captain Maya.

Before you write a single prompt, you need to think like a product person. Ask yourself:

*Who uses this?* Window installers, on a laptop or tablet at the customer's home. It needs to be simple, fast, and work on a tablet screen.

*What's the core action?* Enter measurements, see the preview, send the quote. That's the flow. Everything else is secondary.

*What data do we need to store?* Customers (name, address, phone). Window models (name, dimensions, price per square metre). Quotes (customer, window model, measurements, total price, date).

*What's the "wow" moment?* The 3D preview. The customer stands in their living room and sees, on a tablet, exactly what the new window will look like in their wall. That's what makes this better than a Word document.

You just designed an app. No code. No technical degree. Just clear thinking about who needs what.

== Breaking It Into Jobs

Now we break the project into pieces. Each piece is a self-contained job you'll give to the agent. The key principle: each job should make sense on its own, produce a testable result, and build on the previous one.

=== Job 1: Set Up the Project

This is the foundation. You're telling the agent to build the empty building before you start furnishing rooms.

"Create a new project with a Django backend and a React frontend. Set up a Postgres database with three models: Customer (name, email, phone, address), WindowModel (name, width range, height range, glass type, price per square metre), and Quote (linked to a customer and window model, wall width, wall height, window width, window height, window position x, window position y, total price, date created). Create a Django admin panel so I can add window models manually. Make sure the React app can talk to the Django backend through an API."

That's one prompt. It sets up the entire stack from Chapter 3 — the dining room, the kitchen, and the pantry. The agent will create dozens of files, configure the database, set up the API, and wire everything together.

When it's done, you should be able to open the Django admin panel in your browser, add a window model, and see it returned from the API. That's your verification. If that works, the foundation is solid.

=== Job 2: The Quote Form

Now we build the interface where the installer enters information.

"Build a page in the React app with a form for creating a new quote. The form should have: a dropdown to select an existing customer or a button to add a new one, a dropdown to select a window model, number inputs for wall width, wall height, window width, window height, and window position (horizontal and vertical, measured from the bottom-left corner of the wall). All measurements should be in centimetres. When the user fills in the measurements and selects a model, show the calculated price below the form: window area in square metres multiplied by the model's price per square metre, plus a fixed installation fee of 1,500 DKK. Add a Save Quote button that sends the data to Django."

Notice the level of detail. You've specified the fields, the unit, the pricing formula, and the interaction. The agent doesn't have to guess anything.

=== Job 3: The 3D Preview

This is the showpiece — and the part that sounds scariest for a non-programmer. It's not. You're not writing Three.js code. You're describing a scene.

"Using the Three.js library, add a 3D preview panel next to the quote form. The preview should show:

- A wall, rendered as a flat beige rectangle, using the wall width and height from the form
- A rectangular cutout in the wall where the window goes, positioned based on the form's window position and size values
- A glass pane in the cutout — slightly transparent, with a light blue tint
- A simple window frame around the glass, dark grey, 5 centimetres thick
- The camera should start at a slight angle so you can see the wall has a little depth (make the wall 20cm thick)
- The user should be able to rotate the view by dragging with their mouse (use OrbitControls)
- Add soft ambient lighting and one directional light from the upper right so the glass has a subtle reflection
- The scene should update live as the user changes measurements in the form

Put the form on the left side of the screen and the 3D preview on the right. On tablet screens, stack them vertically with the preview on top."

You've just described a 3D scene. Like telling a set designer what you want on stage. The agent knows Three.js. Your job is knowing what a window installation should look like — and _that_, your uncle can tell you in his sleep.

=== Job 4: The PDF Quote

"When the user clicks Save Quote, generate a PDF with: a header with the company name 'Hansen Vinduer' and logo (I'll provide the logo file later), the customer's name and address, a table with the window specifications (model, dimensions, glass type), the 3D preview rendered as a static image, the price breakdown (window area, price per square metre, installation fee, total), and a footer with the company's contact information and CVR number. Use the WeasyPrint library for PDF generation on the Django side. After saving, show a 'Download PDF' button and an 'Email to Customer' button."

=== Job 5: Quote History

"Add a page that lists all past quotes. Show them in a table with columns: date, customer name, window model, total price, and status (draft or sent). The user should be able to click any row to open the full quote. Add a search box that filters by customer name. Sort by date, newest first."

=== Job 6: Polish

"Style the entire app to look clean and professional. Use a colour scheme of navy blue (hex 1a365d) for the header and buttons, white for card backgrounds, light grey (hex f7f7f7) for the page background. Make all buttons and form inputs large enough to tap easily on a tablet. Add the company name 'Hansen Vinduer' in the header. Make sure everything works on an iPad in landscape orientation."

== The Three.js Moment

Let's zoom in on Job 3, because it illustrates the most important lesson in this chapter: you can direct an agent to use technology you've never heard of.

Three.js is a library that draws 3D graphics in a web browser. You've never used it. You've probably never heard of it. And you don't need to learn it. You need to learn how to _describe what you want in 3D_.

The agent knows the library. You know the domain. That combination is more powerful than either alone.

When the first version comes back, it won't be perfect. Maybe the wall is inside-out — you're looking at the interior face instead of the exterior. Maybe the glass is too opaque. Maybe the camera starts inside the wall, looking out.

This is normal. You iterate:

- "The wall is showing the back side. Flip it so we see the exterior face."
- "The glass is too dark. Make it 80% transparent with just a hint of blue."
- "The camera starts too close. Move it back so I can see the whole wall."
- "When I change the window width, the frame doesn't resize. Make the frame update in real time as I type."

Each fix takes the agent about thirty seconds. You're directing, not debugging. You're the client sitting with the architect, saying "move that window a bit to the left." The architect does the drawing.

== What You'll Hit Along the Way

Let's be honest about the bumps, because they're part of the process:

*The agent will make assumptions.* In Job 1, it might set up the database differently than you expected. Maybe it puts the price on the Quote instead of calculating it. Review the output. If something's off, say so.

*Things will break between jobs.* Job 2 might not connect properly to what Job 1 created. The API endpoint might have a different name than the frontend expects. This is normal in software development — it's called _integration_. Tell the agent: "The form is trying to send data to `/api/quotes/` but the API endpoint is at `/api/quote/create/`. Fix the frontend to use the correct endpoint."

*The 3D preview will look weird at first.* 3D graphics are fiddly. Lighting, camera angles, material properties — they all need tuning. This is the most iterative part of the project. Budget extra time here.

*The PDF won't look professional immediately.* PDF generation is notoriously finicky. The spacing will be off. The logo will be the wrong size. The table won't align. Iterate. Each fix is specific and quick.

== The Weekend Timeline

Here's a realistic schedule:

*Saturday morning:* Jobs 1 and 2. Set up the project and build the form. By lunch, you can enter quote data and save it.

*Saturday afternoon:* Job 3. The 3D preview. This takes the most iteration. By dinner, you have a rotating 3D wall with a window in it that updates as you change the form.

*Sunday morning:* Job 4. PDF generation. By mid-morning, you can generate a professional quote document.

*Sunday afternoon:* Jobs 5 and 6. Quote history and polish. By evening, the app looks and works like a real product.

Seven jobs. Two days. An app that makes your uncle look like a company ten times his size.

== The Bigger Lesson

You never wrote a line of code. But you made every decision that mattered. You decided the data model. You decided the user flow. You decided what the 3D preview should look like. You decided the pricing formula. You decided the visual design.

The agent typed the code. You did the thinking. And the thinking — the understanding of the domain, the taste for what looks professional, the judgment about what the user needs — that's the part no agent can do.

This is what it means to be a crew member who directs. Not a passenger. Not a captain. Someone who knows the waters, sees the currents, and tells the crew which way to sail.
