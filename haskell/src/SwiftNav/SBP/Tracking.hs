{-# OPTIONS_GHC -fno-warn-unused-imports #-}
-- |
-- Module:      SwiftNav.SBP.Tracking
-- Copyright:   Copyright (C) 2015 Swift Navigation, Inc.
-- License:     LGPL-3
-- Maintainer:  Mark Fine <dev@swiftnav.com>
-- Stability:   experimental
-- Portability: portable
--
-- Satellite code and carrier-phase tracking messages from the device.

module SwiftNav.SBP.Tracking where

import BasicPrelude
import Control.Lens
import Control.Monad.Loops
import Data.Aeson.TH           (defaultOptions, deriveJSON, fieldLabelModifier)
import Data.Binary
import Data.Binary.Get
import Data.Binary.IEEE754
import Data.Binary.Put
import Data.ByteString
import Data.ByteString.Lazy    hiding (ByteString)
import Data.Int
import Data.Word
import SwiftNav.SBP.Encoding
import SwiftNav.SBP.TH
import SwiftNav.SBP.Types
import SwiftNav.SBP.Gnss

msgTrackingStateDetailed :: Word16
msgTrackingStateDetailed = 0x0011

-- | SBP class for message MSG_TRACKING_STATE_DETAILED (0x0011).
--
-- The tracking message returns a set tracking channel parameters for a single
-- tracking channel useful for debugging issues.
data MsgTrackingStateDetailed = MsgTrackingStateDetailed
  { _msgTrackingStateDetailed_recv_time  :: Word64
    -- ^ Receiver clock time.
  , _msgTrackingStateDetailed_tot        :: GpsTime
    -- ^ Time of transmission of signal from satellite.
  , _msgTrackingStateDetailed_P          :: Word32
    -- ^ Pseudorange observation.
  , _msgTrackingStateDetailed_P_std      :: Word16
    -- ^ Pseudorange observation standard deviation.
  , _msgTrackingStateDetailed_L          :: CarrierPhase
    -- ^ Carrier phase observation with typical sign convention. Only valid when
    -- PLL pessimistic lock is achieved.
  , _msgTrackingStateDetailed_cn0        :: Word8
    -- ^ Carrier-to-Noise density
  , _msgTrackingStateDetailed_lock       :: Word16
    -- ^ Lock indicator. This value changes whenever a satellite signal has lost
    -- and regained lock, indicating that the carrier phase ambiguity may have
    -- changed.
  , _msgTrackingStateDetailed_sid        :: GnssSignal
    -- ^ GNSS signal identifier.
  , _msgTrackingStateDetailed_doppler    :: Int32
    -- ^ Carrier Doppler frequency.
  , _msgTrackingStateDetailed_doppler_std :: Word16
    -- ^ Carrier Doppler frequency standard deviation.
  , _msgTrackingStateDetailed_uptime     :: Word32
    -- ^ Number of seconds of continuous tracking. Specifies how much time signal
    -- is in continuous track.
  , _msgTrackingStateDetailed_clock_offset :: Word16
    -- ^ TCXO clock offset.
  , _msgTrackingStateDetailed_clock_drift :: Word16
    -- ^ TCXO clock drift.
  , _msgTrackingStateDetailed_corr_spacing :: Word16
    -- ^ Early-Prompt (EP) and Prompt-Late (PL) correlators spacing.
  , _msgTrackingStateDetailed_acceleration :: Word8
    -- ^ Acceleration. Valid only when acceleration valid flag is set.
  , _msgTrackingStateDetailed_sync_flags :: Word8
    -- ^ Synchronization status flags.
  , _msgTrackingStateDetailed_tow_flags  :: Word8
    -- ^ TOW status flags.
  , _msgTrackingStateDetailed_track_flags :: Word8
    -- ^ Tracking loop status flags.
  , _msgTrackingStateDetailed_nav_flags  :: Word8
    -- ^ Navigation data status flags.
  , _msgTrackingStateDetailed_pset_flags :: Word8
    -- ^ Parameters sets flags.
  , _msgTrackingStateDetailed_misc_flags :: Word8
    -- ^ Miscellaneous flags.
  } deriving ( Show, Read, Eq )

instance Binary MsgTrackingStateDetailed where
  get = do
    _msgTrackingStateDetailed_recv_time <- getWord64le
    _msgTrackingStateDetailed_tot <- get
    _msgTrackingStateDetailed_P <- getWord32le
    _msgTrackingStateDetailed_P_std <- getWord16le
    _msgTrackingStateDetailed_L <- get
    _msgTrackingStateDetailed_cn0 <- getWord8
    _msgTrackingStateDetailed_lock <- getWord16le
    _msgTrackingStateDetailed_sid <- get
    _msgTrackingStateDetailed_doppler <- fromIntegral <$> getWord32le
    _msgTrackingStateDetailed_doppler_std <- getWord16le
    _msgTrackingStateDetailed_uptime <- getWord32le
    _msgTrackingStateDetailed_clock_offset <- getWord16le
    _msgTrackingStateDetailed_clock_drift <- getWord16le
    _msgTrackingStateDetailed_corr_spacing <- getWord16le
    _msgTrackingStateDetailed_acceleration <- getWord8
    _msgTrackingStateDetailed_sync_flags <- getWord8
    _msgTrackingStateDetailed_tow_flags <- getWord8
    _msgTrackingStateDetailed_track_flags <- getWord8
    _msgTrackingStateDetailed_nav_flags <- getWord8
    _msgTrackingStateDetailed_pset_flags <- getWord8
    _msgTrackingStateDetailed_misc_flags <- getWord8
    return MsgTrackingStateDetailed {..}

  put MsgTrackingStateDetailed {..} = do
    putWord64le _msgTrackingStateDetailed_recv_time
    put _msgTrackingStateDetailed_tot
    putWord32le _msgTrackingStateDetailed_P
    putWord16le _msgTrackingStateDetailed_P_std
    put _msgTrackingStateDetailed_L
    putWord8 _msgTrackingStateDetailed_cn0
    putWord16le _msgTrackingStateDetailed_lock
    put _msgTrackingStateDetailed_sid
    putWord32le $ fromIntegral _msgTrackingStateDetailed_doppler
    putWord16le _msgTrackingStateDetailed_doppler_std
    putWord32le _msgTrackingStateDetailed_uptime
    putWord16le _msgTrackingStateDetailed_clock_offset
    putWord16le _msgTrackingStateDetailed_clock_drift
    putWord16le _msgTrackingStateDetailed_corr_spacing
    putWord8 _msgTrackingStateDetailed_acceleration
    putWord8 _msgTrackingStateDetailed_sync_flags
    putWord8 _msgTrackingStateDetailed_tow_flags
    putWord8 _msgTrackingStateDetailed_track_flags
    putWord8 _msgTrackingStateDetailed_nav_flags
    putWord8 _msgTrackingStateDetailed_pset_flags
    putWord8 _msgTrackingStateDetailed_misc_flags

$(deriveSBP 'msgTrackingStateDetailed ''MsgTrackingStateDetailed)

$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_msgTrackingStateDetailed_" . stripPrefix "_msgTrackingStateDetailed_"}
             ''MsgTrackingStateDetailed)
$(makeLenses ''MsgTrackingStateDetailed)

-- | TrackingChannelState.
--
-- Tracking channel state for a specific satellite signal and measured signal
-- power.
data TrackingChannelState = TrackingChannelState
  { _trackingChannelState_state :: Word8
    -- ^ Status of tracking channel
  , _trackingChannelState_sid :: GnssSignal
    -- ^ GNSS signal being tracked
  , _trackingChannelState_cn0 :: Float
    -- ^ Carrier-to-noise density
  } deriving ( Show, Read, Eq )

instance Binary TrackingChannelState where
  get = do
    _trackingChannelState_state <- getWord8
    _trackingChannelState_sid <- get
    _trackingChannelState_cn0 <- getFloat32le
    return TrackingChannelState {..}

  put TrackingChannelState {..} = do
    putWord8 _trackingChannelState_state
    put _trackingChannelState_sid
    putFloat32le _trackingChannelState_cn0
$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_trackingChannelState_" . stripPrefix "_trackingChannelState_"}
             ''TrackingChannelState)
$(makeLenses ''TrackingChannelState)

msgTrackingState :: Word16
msgTrackingState = 0x0013

-- | SBP class for message MSG_TRACKING_STATE (0x0013).
--
-- The tracking message returns a variable-length array of tracking channel
-- states. It reports status and carrier-to-noise density measurements for all
-- tracked satellites.
data MsgTrackingState = MsgTrackingState
  { _msgTrackingState_states :: [TrackingChannelState]
    -- ^ Signal tracking channel state
  } deriving ( Show, Read, Eq )

instance Binary MsgTrackingState where
  get = do
    _msgTrackingState_states <- whileM (not <$> isEmpty) get
    return MsgTrackingState {..}

  put MsgTrackingState {..} = do
    mapM_ put _msgTrackingState_states

$(deriveSBP 'msgTrackingState ''MsgTrackingState)

$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_msgTrackingState_" . stripPrefix "_msgTrackingState_"}
             ''MsgTrackingState)
$(makeLenses ''MsgTrackingState)

-- | TrackingChannelCorrelation.
--
-- Structure containing in-phase and quadrature correlation components.
data TrackingChannelCorrelation = TrackingChannelCorrelation
  { _trackingChannelCorrelation_I :: Int32
    -- ^ In-phase correlation
  , _trackingChannelCorrelation_Q :: Int32
    -- ^ Quadrature correlation
  } deriving ( Show, Read, Eq )

instance Binary TrackingChannelCorrelation where
  get = do
    _trackingChannelCorrelation_I <- fromIntegral <$> getWord32le
    _trackingChannelCorrelation_Q <- fromIntegral <$> getWord32le
    return TrackingChannelCorrelation {..}

  put TrackingChannelCorrelation {..} = do
    putWord32le $ fromIntegral _trackingChannelCorrelation_I
    putWord32le $ fromIntegral _trackingChannelCorrelation_Q
$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_trackingChannelCorrelation_" . stripPrefix "_trackingChannelCorrelation_"}
             ''TrackingChannelCorrelation)
$(makeLenses ''TrackingChannelCorrelation)

msgTrackingIq :: Word16
msgTrackingIq = 0x001C

-- | SBP class for message MSG_TRACKING_IQ (0x001C).
--
-- When enabled, a tracking channel can output the correlations at each update
-- interval.
data MsgTrackingIq = MsgTrackingIq
  { _msgTrackingIq_channel :: Word8
    -- ^ Tracking channel of origin
  , _msgTrackingIq_sid   :: GnssSignal
    -- ^ GNSS signal identifier
  , _msgTrackingIq_corrs :: [TrackingChannelCorrelation]
    -- ^ Early, Prompt and Late correlations
  } deriving ( Show, Read, Eq )

instance Binary MsgTrackingIq where
  get = do
    _msgTrackingIq_channel <- getWord8
    _msgTrackingIq_sid <- get
    _msgTrackingIq_corrs <- replicateM 3 get
    return MsgTrackingIq {..}

  put MsgTrackingIq {..} = do
    putWord8 _msgTrackingIq_channel
    put _msgTrackingIq_sid
    mapM_ put _msgTrackingIq_corrs

$(deriveSBP 'msgTrackingIq ''MsgTrackingIq)

$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_msgTrackingIq_" . stripPrefix "_msgTrackingIq_"}
             ''MsgTrackingIq)
$(makeLenses ''MsgTrackingIq)

-- | TrackingChannelStateDepA.
--
-- Deprecated.
data TrackingChannelStateDepA = TrackingChannelStateDepA
  { _trackingChannelStateDepA_state :: Word8
    -- ^ Status of tracking channel
  , _trackingChannelStateDepA_prn :: Word8
    -- ^ PRN-1 being tracked
  , _trackingChannelStateDepA_cn0 :: Float
    -- ^ Carrier-to-noise density
  } deriving ( Show, Read, Eq )

instance Binary TrackingChannelStateDepA where
  get = do
    _trackingChannelStateDepA_state <- getWord8
    _trackingChannelStateDepA_prn <- getWord8
    _trackingChannelStateDepA_cn0 <- getFloat32le
    return TrackingChannelStateDepA {..}

  put TrackingChannelStateDepA {..} = do
    putWord8 _trackingChannelStateDepA_state
    putWord8 _trackingChannelStateDepA_prn
    putFloat32le _trackingChannelStateDepA_cn0
$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_trackingChannelStateDepA_" . stripPrefix "_trackingChannelStateDepA_"}
             ''TrackingChannelStateDepA)
$(makeLenses ''TrackingChannelStateDepA)

msgTrackingStateDepA :: Word16
msgTrackingStateDepA = 0x0016

-- | SBP class for message MSG_TRACKING_STATE_DEP_A (0x0016).
--
-- Deprecated.
data MsgTrackingStateDepA = MsgTrackingStateDepA
  { _msgTrackingStateDepA_states :: [TrackingChannelStateDepA]
    -- ^ Satellite tracking channel state
  } deriving ( Show, Read, Eq )

instance Binary MsgTrackingStateDepA where
  get = do
    _msgTrackingStateDepA_states <- whileM (not <$> isEmpty) get
    return MsgTrackingStateDepA {..}

  put MsgTrackingStateDepA {..} = do
    mapM_ put _msgTrackingStateDepA_states

$(deriveSBP 'msgTrackingStateDepA ''MsgTrackingStateDepA)

$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_msgTrackingStateDepA_" . stripPrefix "_msgTrackingStateDepA_"}
             ''MsgTrackingStateDepA)
$(makeLenses ''MsgTrackingStateDepA)
