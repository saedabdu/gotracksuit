# Instructions

Hello, and thanks for taking the time to interview with us at Tracksuit! This is
a take-home exercise we'd like you to complete. This shouldn't be hard and
shouldn't take very long — if it takes more than a few hours you're
over-thinking it!

<!-- deno-fmt-ignore-start -->
> [!Note]
> This task is meant to give us something to talk over in your technical
> interview. It should feel similar to the kind of day-to-day work you're used
> to doing. We're not trying to trick you with something that requires anything
> fancy to solve.
<!-- deno-fmt-ignore-end -->

## Background

Imagine you are an SRE at a promising startup called Suit Tracker Inc. Here
at Suit Tracker, we have a huge network of well-paid interns that hang out at
malls and note down what people are wearing out there in the wild. We then get
our data science team to tell us what it all means.

Our office fax is ringing off the hook with potential customers wanting to sign
up to receive our fashion insights.

<p align="center">
   <img height="250" src="./assets/cs-team.jpg">
</p>

Right now we're faxing reports every month to our customers with our findings.
But as we get more and more customers we're having problems keeping up with the
number of reports we have to send out every month.

If only there were a better way. 🤷

## Solution

We're working on a new feature in our World Wide Web app called _Insights_,
which will allow customers to log in and see what data science has found out,
all without us having to fax anything out at all! We think this is the key to
taking our business to the next level.

## The Task

One of our top developers, Chuggs, has been working on it. But we've just found
out they were injured in a terrible interview accident, and they were unable to
ship the new service they've been working on. We need your help to get the
project over the line.

Before they went under for surgery, Chuggs told us the work was nearly complete
and everything done so far is pretty much flawless. Another developer will be
picking up the remaining work, but in the meantime, we need to deploy what we
have.

So, we need you to:

1. Dockerise the backend application for deployment

2. Tell us what we need to get the frontend application accessible from the web.

3. Stab out a CI pipeline that shows how shipping the apps in this codebase
   should work.

Don't worry about deploying to real infra--just get something credible in place
we can talk about.

Since we need to store data in this application, we use a relational DB for
persistence. Chuggs has tested all the main ones and found that SQLite was by
far the fastest, so that's what they used in the implementation.

Finally, while Chuggs is definitely a 100x developer thanks to AI, they haven't
had a chance to flesh out the monitoring and observability for this application.

- What do you think we need in place, and are there any changes to the
  implementation we might need to make to accomplish this?

### Implementation notes

- The backend app is an HTTP server
  - the build goes to `server/build/server`; it's an x86_64 ELF binary by default
  - at runtime, it has a health endpoint at `GET /_health`
  - Deno has a fine-grained security model; you might need to run with extra
    flags to avoid interactive permissions prompts ([documentation](https://docs.deno.com/runtime/fundamentals/security/))
  - the application uses SQLite for data storage.

- The frontend is bundled into static assets
  - the build goes to `client/build/*`; this includes HTML, JS and other assets
    for deployment.

## Extra For Experts

Our eccentric American investor tells us that we'll unlock a huge funding
milestone if we get this Insights feature working--they will personally
helicopter us a briefcase of sequentially-numbered USD bills for our next
funding round if we can pull this off.

We're confident you've got this, so we're already planning to scale our
engineering team at Suit Tracker from ~~5~~ 4 engineers to 20.

In your opinion:

- what kinds of things will SRE need to put in place for us to scale the team
  out and collaborate on this product more effectively?
