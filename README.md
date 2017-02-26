CS3217 Problem Set 5
==

**Name:** Yong Lin Han

**Matric No:** A0139498J

**Tutor:** Jinghan

### Rules of Your Game

1) Clear all normal bubbles from the grid to win. Normal bubbles are the colored bubbles without any markings on them. <br>
2) Notice the whole dotted line above the cannon? You lose once you try to fire a bubble at a snapped bubble in the row directly above the white dotted line, and the resulting snap location of this new bubble is below the line, even if this bubble will be able to clear some bubbles after snapping. <br>
3) Special Bubbles: <br>
Indestructible: Cannot be removed by clustering or any other special bubble, can only be removed by dropping. <br>
Lightning: Removes all bubbles in same row as it (Except indestructible). <br>
Bomb: Removes its adjacent neighbouring bubbles. (Except indestructible) <br>
Star: "Takes Revenge" on whichever bubble destroyed it, by activating all types of that bubble in the grid. <br>
4) Priority of special bubbles activation: If a newly shot bubble snaps to a grid with neighbouring star, lightning and bomb bubbles, the order of activation is star -> lightning -> bomb, and then clustering. This is needed to handle ambiguity as to which bubble activated the star. Clustering will always occur even if the bubble also activated a special bubble. <br>
5) Limited shots mode: Every shot counts! Game is over as soon as you try to fire a shot without having any shots left in the cannon. The count is shown on the base of cannon. <br>
6) Timed mode: Game is over when timer reaches 0.  The timer is shown just above the cannon. <br>
7) Preloaded levels: The game comes with a few preloaded levels. These levels may be modified by the user in any way, and resaved. However, if these levels are deleted, upon the next starting of the application, they will be loaded in again. (Unless the user circumvents this by creating a level with the same name as a preloaded level).

### Problem 1: Cannon Direction

The user simply has to tap or pan & release on the screen. In the case of a tap, the cannon will fire projectile towards the tap location. In the case of a pan, the cannon rotates to follow the user's touch location, and upon release, will fire projectile towards the last touch location.



### Problem 2: Upcoming Bubbles

The decision I have made is to only generate upcoming bubbles that are colors of existing bubbles in the grid. <br>

Rationale for this: I have 7 normal bubbles. If I do not restrict the colors, then the game will be quite luck dependent. Also, the dominant strategy would be to chain bubbles downwards until you find a color that can pop a bubble at the top of the chain. It would make ending the game tedious and difficult. Because I also have timed and limited shots mode with varying difficulties, it makes sense to restrict the bubble colors to allow for less luck dependent gameplay. It also allows for several viable gameplay strategies: E.g. To focus on clearing one bubble color at a time, or just clearing as many bubbles as possible?

My RandomBubbleHelper will generate a random bubble in the range of normal bubble types, and retries until it gets a bubble type that is currently in the grid. <br>

At any one time, the user knows about the colors of the next two bubbles he will be firing. Because of my "only generate bubble in grid" condition, my RandomBubbleHelper lazily generates a new bubble upon projectile fired (Exception: At start of game, it has to generate two bubbles). There is a corner case which I handled as well, drawing inspiration from bubble mania games I tried. Suppose the next two upcoming bubbles are blue bubbles, but firing one of them will clear all blue bubbles from the grid. Upon snapping, the next blue bubble(s) will magically change color to another color that is in the grid. Of course, this only happens if you wait for the bubble to snap before firing the next bubble off, bubbles won't change color in mid-flight.


### Problem 3: Integration

Well, integration of my game engine with level designer was simply doing a segue from level designer's start button to the game view storyboard, passing level designer's modelManager reference along. Because my GameViewController originally created its own instance of modelManager, replacing this created instance with a passed instance would not break any functionality in my game engine.<br>

However, I discovered a small problem: After playing out the level in gameview and clearing some of the bubbles in the grid, when I unwind back to level designer, the designed level would be changed to the cleared level, which definitely feels weird. This occurred because modelManager is a class, passing a reference instead of value to the GameViewController. I thought of changing modelManager to be a struct instead, but realised that I did not want it to be a struct since I want to control when to copy and when to pass by reference. As such, I decided to implement NSCopying in modelManager, so that I can pass a copy of the model component to the game level, allowing for no change when I unwind back to level design. I used the same strategy of copying to implement the retry functionality in the game level as well.

To reduce code duplication, I also removed the CollectionView-related protocol implementations in GameViewController, and used the same datasource and delegateflowlayout class as LevelDesignViewController. I used a boolean value to track in the datasource class which viewcontroller it belongs to, and modify the visibility of grid cell borders, and number of grid cells accordingly (I removed the last row from level designer view, to allow for some leeway in user created levels). While an enum might be better suited for this purpose in terms of extensibility, since I only plan to have two different types of the collectionview, I decided that a boolean value would suffice for its simplicity. <br>

While this part of integration might be simple, as I worked on subsequent sections such as the Game Flow, I had make several modifications. For example, to account for unwind segue back to multiple locations, I used a string constant unwindSegueIdentifier to track which viewcontroller to unwind to. This had to be passed in segues as well.

Also, as I implemented multiple viewcontrollers in the app, I had to keep passing along the model and storage references from the appdelegate to every viewcontroller I segue to, if they require access to these components. As a result, I had to make the attribute model and storage in these classes optional, and have to unwrap them with guard everytime I wanted to access them. This was a little tedious and felt unintuitive. For storageManager, perhaps an alternative would be to change it into a singleton class, for the easy global reference to it from any class. This would eliminate the need for me to pass storage around. However, this would make unit testing of storageManager hard since a singleton is not easily testable.


### Problem 4.3

I thought of and used a simple strategy to chain bubbles. Since I support full chaining (in the sense of e.g. lightning destroy star, star destroy all lightning, a destroyed lightning destroy bomb, this bomb destroy another star, this star will destroy all bomb...), I had to think of a simple way to account for such behavior, that will minimise risk of bugs. <br>

My solution is to have an activate() function. This function takes in a bubble and an activatorbubble, and activates bubble with the activatorbubble, by (trying) to remove it (theres indestructible bubbles), and also unleashing the bubble's special effect. This allows me to specify which action to take, depending on the type of bubble. <br>

For example, suppose a newly shot bubble landed next to a lightning bubble. The newly shot bubble will activate the lightning bubble, which calls the function zapAllBubblesOnSameRow(). In this function, for each bubble in the same row as the lightning bubble, I will call activate() on it, passing in the proper arguments. If one of these bubbles is a star bubble, when I call activate(star, lightning), the next function activateAllBubblesWithSameType() will be called, which in turns activates all the lightning bubbles, and for each of these activated lightning bubble, it will activate each of the bubble on same row as it, and so on..

The beauty of the activate() function is that I can reuse it and customise what behavior to take depending on the activated and activator bubble. If I want to add additional animations, I can do so easily. To block removal of indestructible bubbles, all I have to do is to return if bubble's type is indestructible. I do not have to keep checking the type of each bubble as I write some complicated algorithm with several layered nested loops. As a result, my code for supporting the special bubbles and chaining is very short, neat and readable, allowing for ease of maintainability and extension.

### Problem 7: Class Diagram

Please save your diagram as `class-diagram.png` in the root directory of the repository.

### Problem 8: Testing

Please refer to `testing.txt`.

### Problem 9: The Bells & Whistles
<ul>
<li> Add animations: bubble burst, bomb, lightning.</li>
<li> Add game score. </li>
<li> Add end game screen with stats.</li>
<li> Limited cannon shots mode with 3 levels of difficulty.</li>
<li> Timed mode with 3 levels of difficulty.</li>
<li> Unconnected bubbles won't appear in game start + Handle default win case for levels.</li>
<li> Upcoming bubbles are restricted to those found in grid only, and replacement occurs if needed.</li>
<li> Level selection screen shows image preview of levels.</li>
<li> Support level deletion.</li>
<li> Complete and fun chaining behavior for all special bubbles.</li>
<li> Indestructible bubble that is indestructible.</li>
</ul>

### Problem 10: Final Reflection

The original design of my MVC architecture was pretty decent for the purposes of this application I feel. <br>
One improvement I observed: When I first designed the Storage component of the game, I only thought to save the gridState (2D array) to file. Later on, I realised that I could save additional information like high score for a particular level with it, or even include information to show if the level is a preloaded or custom made one. Even though I did not end up doing these extensions, I did change the Storage to store a Level object instead, making it easier to include more details about the level to be saved if needed. <br>
Otherwise, I like the design of my Level Design ViewController. Because I had extracted the CollectionView related functions from it, I was able to easily reuse the extracted components for my GameViewController as well. I had originally thought that I would extract just to make the initial view controller less lengthy, but it turned out I can eliminate alot of code duplication for this. <br>
Also, it was very easy for me to add new bubble types into the game. Using the button's tag as the bubble type's raw value proved to be a great choice since I did not have to tweak the cycle and etc functionalities associated with the level designer. <br>
Separating the storage component from model was also a great choice, as I did not have to worry about breaking the functionalities of either component when tweaking one, allowing me to modify the existing class easily. <br>
Further improvement of architecture seems like it would take a great deal of consideration, because the separation of concerns is already quite clear. Maybe one area which I had doubts about would be regarding the collectionview required implementations. As a data source class, my bubble grid data source is only responsible for initialising the empty grid and this might go against what it seems to be responsible for. Perhaps there is a way to tweak this class to hold a reference to ModelManager, and use reload grid when receiving updates from modelManager though a notification. However, if I do that, I would not be able to reuse it for the GameViewController.

Regarding my game engine design, I like it alot since I was able to add in the extra features easily. <br>
One possible improvement: I often wondered if my GameViewController really needed to have a CollectionView, since the CollectionView is only used to guide where the bubbles should snap to, with the convenient point to index path conversion API. It can be quite weird for the collectionview to just be doing that. If I could implement the snap to grid in another way, then perhaps I do not need the collectionview in my GameViewController after all.<br>
Another possible improvement: Because of the way I structure my game engine, I will only delete the bubbles together in one pass when it is the game renderer's turn to run, since the renderer only handles the drawing of game objects after the logic is done. Also, all my animations regarding gameplay objects are handled in Animation Renderer. This makes it hard for me to extend my animations to take place simultaneously as the logic is doing its job, and prevented me from implementing e.g. a chain explosion effect which in my opinion would look cooler. To change this, it seems that I would need to either run the renderer & gamelogic in parallel or somehow store the order that each bubble to be deleted, only use the renderer to update it when appropriate. Of course, the easiest way would be for the game logic to do the animation itself, or hold a reference to the renderer (or maybe through a delegate protocol), and call the delegate to do the animation each time the removal occurs. After some thought it seems that the delegate way is most appropriate. <br>
Another possible improvement I thought about: Do I really need so many classes for my special bubbles? Is it better to have a special bubble enum, and maybe let these special bubbles inherit from e.g. SpecialBubble. For the purposes of this app there isn't really a difference with either options. I suppose if there is a huge amount of special bubbles that share certain common characteristics, then it would make sense to group them together and put their common stuff inside this SpecialBubble class.
<br>
Other than that, I liked the design of my Physics Engine as it did not have to know about GameObjects at all. Not sure if that will affect the cocoapods making, but regardless separation of concerns is always good. Since my Game Engine is overall decently structured, I have a clear idea about which component of my app is doing what, and it makes it easier for me to isolate bugs and discover what went wrong. <br>
I also liked that I separated GameLogic from GameLevelScene in PS4. It allowed me to easily implement and extend functionalities in PS5 such as shooting of multiple projectiles and new bubble types, since it is clear that GameLogic is responsible for post-snap behavior only.
