define ['cmx/bone'], (Bone) ->

  class Skelet

    constructor: (bonedefs=[]) ->
      @bones = []
      @addBones bonedefs

      @structure = {}

    addBones: (bonedefs=[]) ->
      list = []
      for args in bonedefs
        @bones.push new Bone args...
        list.push @bones.length-1 # push bone index
      list

    addStructure: (defs={}) ->
      for arg, val of defs
        @structure[arg] = val

    boneIndex: (name) ->
      for bone, i in @bones
        return i if name==bone.name
      null

    bone: (name) ->
      index = @boneIndex(name)
      @bones[index]

    bonesWithIndices: (boneIndices) ->
      boneIndices.map (index) =>
        @bones[index]

    moveBone: (boneNames, dx, dy, absolute=no) ->
      boneNames = [boneNames] unless _.isArray boneNames

      for boneName in boneNames
        bone = @boneIndex boneName

        dx = Math.round dx
        dy = Math.round dy

        mx = @bones[bone].x
        my = @bones[bone].y

        if absolute
          @bones[bone].x = dx
          @bones[bone].y = dy
        else
          @bones[bone].x += dx
          @bones[bone].y += dy

        mx -= @bones[bone].x
        my -= @bones[bone].y

        affectedBones = @affectedBones boneName, no
        for boneName in affectedBones
          bone = @boneIndex boneName

          @bones[bone].x -= mx
          @bones[bone].y -= my

    affectedBones: (boneNames, addSelf=yes) ->
      boneNames = [boneNames] unless _.isArray boneNames

      res = []
      for boneName in boneNames
        a = @structure[boneName]
        res = res.concat a if a

      res.concat boneNames if addSelf
      _.uniq res

    getPose: (boneIndices) ->
      pose = []
      for boneIndex in boneIndices
        bone = @bones[boneIndex]
        continue unless bone
        pose.push [bone.x, bone.y]
      pose

    setPose: (pose, boneIndices) ->
      for point, i in pose
        index = boneIndices[i]
        continue if index is undefined
        continue if index >= @bones.length
        @bones[index].x = point[0]
        @bones[index].y = point[1]