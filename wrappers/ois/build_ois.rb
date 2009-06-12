require 'rubygems'
require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

OGRE_RB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

OIS_DIR = File.join(OGRE_RB_ROOT, "lib", "usr")

HERE_DIR = File.join(OGRE_RB_ROOT, "wrappers", "ois")

Extension.new "ois" do |e|
  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "ois")

  e.sources File.join(OIS_DIR, "include", "OIS", "OIS.h"),
    :include_source_dir => File.join(HERE_DIR, "code"),
    :library_paths => File.join(OIS_DIR, "lib"),
    # For our custom code in code/ to find OIS correctly
    :include_paths => File.join(OIS_DIR, "include"),
    :libraries => "OIS",
    :ldflags => "-shared"

  e.module "OIS" do |m|
    node = m.namespace "OIS"

    # Uses crazy STL stuff, ignore for now
    node.classes("FactoryCreator").ignore

    # Hmm, InputManager has protected destructor, causing problems. Ignore them for now
    node.classes("Object").methods("getCreator").ignore

    ##
    # Input Manager
    ##
    im = node.classes("InputManager")
    im.methods("listFreeDevices").ignore

    # createInputObject requires C++ style casting of the return value. We can't do that,
    # so following with Python-Ogre, build some more explicit helpers to this method and
    # export those.
    im.methods("createInputObject").ignore

    decl = <<-END
OIS::Keyboard* _OIS_InputManager_createKeyboard(OIS::InputManager* self, bool buffering) {
  OIS::Keyboard* keyboard = (OIS::Keyboard*) self->createInputObject(OIS::OISKeyboard, buffering);
  return keyboard;
}
OIS::Mouse* _OIS_InputManager_createMouse(OIS::InputManager* self, bool buffering) {
  OIS::Mouse* mouse = (OIS::Mouse*) self->createInputObject(OIS::OISMouse, buffering);
  return mouse;
}
OIS::JoyStick* _OIS_InputManager_createJoyStick(OIS::InputManager* self, bool buffering) {
  OIS::JoyStick* joystick = (OIS::JoyStick*) self->createInputObject(OIS::OISJoyStick, buffering);
  return joystick;
}
END

    wrapping = <<-END
<class>.define_method("create_keyboard", &_OIS_InputManager_createKeyboard);
<class>.define_method("create_mouse", &_OIS_InputManager_createMouse);
<class>.define_method("create_joy_stick", &_OIS_InputManager_createJoyStick);
END

    im.add_custom_code(decl, wrapping)

    node.classes("Exception").ignore

    ##
    # Envelope
    ##
    envelope = node.classes("Envelope")
    envelope.variables.ignore

    # Effect classes deal with force feedback. Ignore these
    # for now
    node.classes.find(:name => /Effect$/).ignore

    ##
    # Ignore other custom factories for now
    ##
    node.structs("WiiMoteFactoryCreator").ignore
    node.structs("LIRCFactoryCreator").ignore

    # TODO Figure out if rb++ can handle this on it's own.
    # When dealing with STL containers, typedef-ing can end 
    # up going both ways. We need to flag classes to not
    # do the reverse typedef lookup
    node.classes("Axis").disable_typedef_lookup
    node.classes("Vector3").disable_typedef_lookup

    ## 
    # JoyStickState
    ##
    node.classes("JoyStickState").variables.ignore 

    ##
    # Keyboard
    ##
    keyboard = node.classes("Keyboard")
    keyboard.methods("isKeyDown").wrap_as("key_down?")
    keyboard.methods("isModifierDown").wrap_as("modifier_down?")

    ##
    # MouseState
    ##
    ms = node.classes("MouseState")
    ms.methods("buttonDown").wrap_as("button_down?")
  end
end

# At completion, copy over the new ois extension
FileUtils.cp File.join(OGRE_RB_ROOT, "generated", "ois", "ois.so"), File.join(OGRE_RB_ROOT, "lib", "ois")
